import os
import shutil

def configure():
    print("Starting Android project customization...")
    
    # 1. Update app/build.gradle with correct applicationId and namespace
    build_gradle_path = "android/app/build.gradle"
    if os.path.exists(build_gradle_path):
        with open(build_gradle_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Replace namespace and applicationId
        # In modern templates, these are set dynamically or as strings
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
    
    # Delete the old generated package folder (usually com/example/... or com/saikumaredutech/...)
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

    # 3. Update AndroidManifest.xml with permissions and AdMob metadata
    manifest_path = "android/app/src/main/AndroidManifest.xml"
    if os.path.exists(manifest_path):
        with open(manifest_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
            
        new_lines = []
        for line in lines:
            new_lines.append(line)
            # Add permissions right after the <manifest tag
            if "<manifest" in line:
                new_lines.append('    <uses-permission android:name="android.permission.INTERNET"/>\n')
                new_lines.append('    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>\n')
            # Add AdMob ID inside the <application tag
            if "<application" in line:
                admob_meta = """        <!-- Google AdMob Application ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>
"""
                new_lines.append(admob_meta)
                
        with open(manifest_path, "w", encoding="utf-8") as f:
            f.writelines(new_lines)
        print("Injected permissions and AdMob metadata into AndroidManifest.xml.")
    else:
        print(f"Error: {manifest_path} not found!")

if __name__ == "__main__":
    configure()
