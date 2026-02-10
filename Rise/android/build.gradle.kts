// File: android/build.gradle.kts

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// --- SUNTIKAN SKRIP (DIPINDAHKAN KE ATAS) ---
// Kita pasang aturan ini DULUAN sebelum Gradle mulai bekerja.
// Ini memaksa semua plugin (ML Kit dll) pakai SDK 36.
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            if (android is com.android.build.gradle.BaseExtension) {
                android.compileSdkVersion(36)
                android.defaultConfig {
                    targetSdkVersion(36)
                }
            }
        }
    }
}
// --------------------------------------------

// Baris ini yang memicu proses build ("Start Engine")
// Makanya dia wajib ditaruh di BAWAH aturan di atas.
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}