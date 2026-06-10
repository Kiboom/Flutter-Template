#!/usr/bin/env python3
"""앱 이름을 한 번에 바꿔주는 스크립트.

template 프로젝트의 패키지 이름, 번들 ID(앱 식별자), 화면에 보이는 앱 이름을
android / iOS / macOS / web / Dart 코드 전체에서 한꺼번에 교체한다.

사용법:
    python3 scripts/rename_app.py my_app
    python3 scripts/rename_app.py my_app --display "My App" --org com.mycompany

인자:
    name            새 패키지 이름. 소문자·숫자·밑줄만. 예) my_app, todo_list
    --display       홈 화면에 보이는 앱 이름. 생략하면 name으로 자동 생성 ("My App")
    --org           번들 ID 앞부분. 생략하면 기존 값 유지. 예) com.mycompany

실행 후 반드시:
    flutter clean && flutter pub get
"""

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def fail(message: str) -> None:
    print(f"\033[31m✗ {message}\033[0m")
    sys.exit(1)


def info(message: str) -> None:
    print(f"  {message}")


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write(path: Path, text: str) -> None:
    path.write_text(text, encoding="utf-8")


def replace_in_file(path: Path, old: str, new: str) -> bool:
    if not path.exists():
        return False
    text = read(path)
    if old not in text:
        return False
    write(path, text.replace(old, new))
    info(f"수정: {path.relative_to(ROOT)}")
    return True


def current_name() -> str:
    match = re.search(r"^name:\s*(\S+)", read(ROOT / "pubspec.yaml"), re.MULTILINE)
    if not match:
        fail("pubspec.yaml에서 현재 패키지 이름을 찾지 못했습니다.")
    return match.group(1)


def current_bundle() -> str:
    gradle = read(ROOT / "android/app/build.gradle.kts")
    match = re.search(r'applicationId\s*=\s*"([^"]+)"', gradle)
    if not match:
        fail("android build.gradle.kts에서 applicationId를 찾지 못했습니다.")
    return match.group(1)


def rename_dart_imports(old: str, new: str) -> None:
    for path in list((ROOT / "lib").rglob("*.dart")) + list((ROOT / "test").rglob("*.dart")):
        replace_in_file(path, f"package:{old}/", f"package:{new}/")


def rename_kotlin_package(old_bundle: str, new_bundle: str) -> None:
    base = ROOT / "android/app/src/main/kotlin"
    old_dir = base / Path(old_bundle.replace(".", "/"))
    new_dir = base / Path(new_bundle.replace(".", "/"))
    activity = old_dir / "MainActivity.kt"
    if not activity.exists():
        info("MainActivity.kt를 찾지 못해 건너뜁니다.")
        return
    text = read(activity).replace(f"package {old_bundle}", f"package {new_bundle}")
    new_dir.mkdir(parents=True, exist_ok=True)
    write(new_dir / "MainActivity.kt", text)
    activity.unlink()
    # 비어 버린 옛 패키지 폴더들을 위로 올라가며 정리한다.
    folder = old_dir
    while folder != base and folder.exists() and not any(folder.iterdir()):
        folder.rmdir()
        folder = folder.parent
    info(f"Kotlin 패키지 이동: {old_bundle} → {new_bundle}")


def rename_iml(old: str, new: str) -> None:
    old_iml = ROOT / f"{old}.iml"
    if old_iml.exists():
        old_iml.rename(ROOT / f"{new}.iml")
        info(f"이름 변경: {old}.iml → {new}.iml")


def set_display_name(old_name: str, display: str) -> None:
    # Android 홈 화면 라벨
    manifest = ROOT / "android/app/src/main/AndroidManifest.xml"
    if manifest.exists():
        text = re.sub(r'android:label="[^"]*"', f'android:label="{display}"', read(manifest))
        write(manifest, text)
        info(f"수정: {manifest.relative_to(ROOT)}")
    # iOS / macOS 표시 이름
    for plist in [ROOT / "ios/Runner/Info.plist", ROOT / "macos/Runner/Configs/AppInfo.xcconfig"]:
        if not plist.exists():
            continue
        text = read(plist)
        text = re.sub(
            r"(<key>CFBundleDisplayName</key>\s*<string>)[^<]*(</string>)",
            rf"\g<1>{display}\g<2>",
            text,
        )
        text = re.sub(r"(PRODUCT_NAME\s*=\s*).*", rf"\g<1>{display}", text)
        write(plist, text)
        info(f"수정: {plist.relative_to(ROOT)}")
    # Web
    index = ROOT / "web/index.html"
    if index.exists():
        text = read(index)
        text = text.replace(f"<title>{old_name}</title>", f"<title>{display}</title>")
        text = re.sub(
            r'(<meta name="apple-mobile-web-app-title" content=")[^"]*"',
            rf'\g<1>{display}"',
            text,
        )
        write(index, text)
        info(f"수정: {index.relative_to(ROOT)}")
    manifest_json = ROOT / "web/manifest.json"
    if manifest_json.exists():
        text = read(manifest_json)
        text = re.sub(r'("name":\s*")[^"]*"', rf'\g<1>{display}"', text)
        text = re.sub(r'("short_name":\s*")[^"]*"', rf'\g<1>{display}"', text)
        write(manifest_json, text)
        info(f"수정: {manifest_json.relative_to(ROOT)}")
    # MaterialApp title
    replace_in_file(ROOT / "lib/core/app.dart", 'title: "Template"', f'title: "{display}"')


def main() -> None:
    parser = argparse.ArgumentParser(description="앱 이름을 한 번에 바꾼다.")
    parser.add_argument("name", help="새 패키지 이름 (소문자·숫자·밑줄). 예) my_app")
    parser.add_argument("--display", help='홈 화면 앱 이름. 예) "My App"')
    parser.add_argument("--org", help="번들 ID 앞부분. 예) com.mycompany")
    args = parser.parse_args()

    new_name = args.name.strip()
    if not re.fullmatch(r"[a-z][a-z0-9_]*", new_name):
        fail("패키지 이름은 소문자로 시작하고 소문자·숫자·밑줄만 쓸 수 있습니다. 예) my_app")

    old_name = current_name()
    if old_name == new_name and not args.org and not args.display:
        fail("현재 이름과 같습니다. 바꿀 내용이 없습니다.")

    old_bundle = current_bundle()
    old_org = old_bundle[: -(len(old_name) + 1)] if old_bundle.endswith(f".{old_name}") else old_bundle.rsplit(".", 1)[0]
    new_org = args.org.strip() if args.org else old_org
    new_bundle = f"{new_org}.{new_name}"
    display = args.display.strip() if args.display else new_name.replace("_", " ").title()

    print(f"\n패키지 이름 : {old_name} → {new_name}")
    print(f"번들 ID    : {old_bundle} → {new_bundle}")
    print(f"표시 이름  : {display}\n")

    replace_in_file(ROOT / "pubspec.yaml", f"name: {old_name}", f"name: {new_name}")
    rename_dart_imports(old_name, new_name)
    rename_kotlin_package(old_bundle, new_bundle)
    bundle_files = [
        ROOT / "ios/Runner.xcodeproj/project.pbxproj",
        ROOT / "macos/Runner.xcodeproj/project.pbxproj",
        ROOT / "macos/Runner/Configs/AppInfo.xcconfig",
    ]
    for path in bundle_files:
        replace_in_file(path, old_bundle, new_bundle)
    replace_in_file(ROOT / "android/app/build.gradle.kts", old_bundle, new_bundle)
    rename_iml(old_name, new_name)
    set_display_name(old_name, display)

    print("\n\033[32m✓ 완료!\033[0m 이제 아래를 실행하세요:")
    print("    flutter clean && flutter pub get\n")


if __name__ == "__main__":
    main()
