buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Add the Google services classpath
        classpath("com.google.gms:google-services:4.3.3") // Use the latest version available
        classpath("com.android.tools.build:gradle:8.5.2") // Stable AGP version for Java 21 compatibility
    }
}
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
