buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
        maven { url = uri("https://oss.sonatype.org/content/repositories/releases") }
        maven { url = uri("https://s01.oss.sonatype.org/content/repositories/releases") }
    }

    val newBuildDir: File = rootProject.projectDir.parentFile.resolve("build").resolve(project.name)
    project.layout.buildDirectory.set(newBuildDir)

    configurations.all {
        resolutionStrategy {
            dependencySubstitution {
                substitute(module("com.arthenica:ffmpeg-kit-https:6.0-2")).using(module("io.github.maitrungduc1410:ffmpeg-kit-https:6.0.1"))
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
