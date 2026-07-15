import os
import shutil
import xml.etree.ElementTree as ET

def configure():
    print("Starting Android project customization...")
    
    # 1. Update app/build.gradle with correct applicationId and namespace
    build_gradle_path = "android/app/build.gradle"
    if os.path.exists(build_gradle_path):
        with open(build_gradle_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Replace namespace and applicationId using regex
        import re
        content = re.sub(
            r'namespace\s+["\'][a-zA-Z0-9._]+["\']', 
            'namespace "com.saikumaredutech.javamaster"', 
            content
        )
        content = re.sub(
            r'applicationId\s+["\'][a-zA-Z0-9._]+["\']', 
            'applicationId "com.saikumaredutech.javamaster"', 
            content
        )
        
        with open(build_gradle_path, "w", encoding="utf-8") as f:
            f.write(content)
        print("Updated app/build.gradle namespace and applicationId.")
    else:
        print(f"Error: {build_gradle_path} not found!")

    # 2. Re-create MainActivity.kt in the correct package folder
    kotlin_src_dir = "android/app/src/main/kotlin"
    
    # Delete the old generated package folder
    if os.path.exists(kotlin_src_dir):
        shutil.rmtree(kotlin_src_dir)
        
    dest_dir = os.path.join(kotlin_src_dir, "com", "saikumaredutech", "javamaster")
    os.makedirs(dest_dir, exist_ok=True)
    
    main_activity_content = """package com.saikumaredutech.javamaster

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}
"""
    with open(os.path.join(dest_dir, "MainActivity.kt"), "w", encoding="utf-8") as f:
        f.write(main_activity_content)
    print("Created MainActivity.kt with package com.saikumaredutech.javamaster.")

    # 3. Update AndroidManifest.xml using robust ElementTree parser
    manifest_path = "android/app/src/main/AndroidManifest.xml"
    if os.path.exists(manifest_path):
        # Register namespace to output clean 'android:' prefix
        android_ns = 'http://schemas.android.com/apk/res/android'
        ET.register_namespace('android', android_ns)
        
        tree = ET.parse(manifest_path)
        root = tree.getroot()
        
        # Add permissions
        permissions = [
            'android.permission.INTERNET',
            'android.permission.ACCESS_NETWORK_STATE'
        ]
        
        # Insert permissions at the top of the root element
        for perm in reversed(permissions):
            exists = False
            for existing in root.findall('uses-permission'):
                if existing.attrib.get(f'{{{android_ns}}}name') == perm:
                    exists = True
                    break
            if not exists:
                perm_el = ET.Element('uses-permission', {
                    f'{{{android_ns}}}name': perm
                })
                root.insert(0, perm_el)
                
        # Add AdMob APPLICATION_ID inside <application> tag
        app_el = root.find('application')
        if app_el is not None:
            admob_key = 'com.google.android.gms.ads.APPLICATION_ID'
            exists = False
            for meta in app_el.findall('meta-data'):
                if meta.attrib.get(f'{{{android_ns}}}name') == admob_key:
                    exists = True
                    break
            if not exists:
                meta_el = ET.Element('meta-data', {
                    f'{{{android_ns}}}name': admob_key,
                    f'{{{android_ns}}}value': 'ca-app-pub-3940256099942544~3347511713'
                })
                app_el.append(meta_el)
                
        # Save back the valid XML file
        tree.write(manifest_path, encoding='utf-8', xml_declaration=True)
        print("Injected permissions and AdMob metadata using XML parser.")
    else:
        print(f"Error: {manifest_path} not found!")

if __name__ == "__main__":
    configure()
