# Java Development Environment

Setup Java development environment with build tools.

## Decision Points

### 1. JDK Distribution

| Option | Pros | Cons | When to Use |
|--------|------|------|-------------|
| **OpenJDK (Ubuntu)** | Simple install via apt | Ubuntu's update cycle | Most development |
| **Eclipse Temurin** | Well-tested, LTS support | Extra repo | Production parity |
| **Amazon Corretto** | AWS optimizations | Extra repo | AWS deployments |
| **GraalVM** | Native compilation, polyglot | Larger, more complex | Native images, performance |

### 2. Java Version

- **21** - Current LTS, recommended
- **17** - Previous LTS, wide compatibility
- **11** - Legacy LTS, older projects
- **22/23** - Latest features (non-LTS)

### 3. Build Tool

| Tool | When to Use |
|------|-------------|
| **Maven** | Most enterprise projects, standard |
| **Gradle** | Android, modern projects, flexible |
| **Both** | When project uses both |

### 4. Additional Tools

- **jq** - JSON processing
- **yq** - YAML processing
- **SDKMAN** - Version management for multiple JDKs

## Cloud-Init Setup

### Minimal Setup (OpenJDK + Maven)

```yaml
packages:
  - openjdk-21-jdk
  - maven

runcmd:
  # Verify installation
  - java -version
  - mvn -version
```

### With Gradle

```yaml
packages:
  - openjdk-21-jdk
  - maven

runcmd:
  # Install Gradle
  - |
    GRADLE_VERSION="8.7"
    wget -q "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -O /tmp/gradle.zip
    unzip -q /tmp/gradle.zip -d /opt
    ln -s /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle
    rm /tmp/gradle.zip
```

### Eclipse Temurin (Adoptium)

For production-aligned JDK:

```yaml
packages:
  - wget
  - apt-transport-https

runcmd:
  # Add Adoptium repository
  - |
    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg
    echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb noble main" > /etc/apt/sources.list.d/adoptium.list
    apt-get update -qq
    apt-get install -y temurin-21-jdk
  
  # Install Maven
  - apt-get install -y maven
```

### With SDKMAN (Version Management)

For environments needing multiple JDK versions:

```yaml
runcmd:
  # Install SDKMAN for user
  - su - USERNAME -c "curl -s https://get.sdkman.io | bash"
  
  # Install Java versions (as user)
  - su - USERNAME -c "source ~/.sdkman/bin/sdkman-init.sh && sdk install java 21.0.2-tem"
  - su - USERNAME -c "source ~/.sdkman/bin/sdkman-init.sh && sdk install maven"
  - su - USERNAME -c "source ~/.sdkman/bin/sdkman-init.sh && sdk install gradle"
```

### GraalVM (Native Images)

```yaml
runcmd:
  # Install GraalVM
  - |
    GRAALVM_VERSION="21.0.2"
    wget -q "https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-${GRAALVM_VERSION}/graalvm-community-jdk-${GRAALVM_VERSION}_linux-x64_bin.tar.gz" -O /tmp/graalvm.tar.gz
    tar -xzf /tmp/graalvm.tar.gz -C /opt
    ln -s /opt/graalvm-community-openjdk-${GRAALVM_VERSION}* /opt/graalvm
    rm /tmp/graalvm.tar.gz
    
    # Set as default
    update-alternatives --install /usr/bin/java java /opt/graalvm/bin/java 100
    update-alternatives --install /usr/bin/javac javac /opt/graalvm/bin/javac 100
  
  # Install native-image
  - /opt/graalvm/bin/gu install native-image
```

## Singularity Setup

### Definition File Section

```singularity
%post
    # Install OpenJDK and Maven
    apt-get install -y openjdk-21-jdk maven
    
    # Install Gradle
    GRADLE_VERSION="8.7"
    wget -q "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -O /tmp/gradle.zip
    unzip -q /tmp/gradle.zip -d /opt
    ln -s /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle
    rm /tmp/gradle.zip

%environment
    export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
    export PATH="$JAVA_HOME/bin:$PATH"
```

## Project-Specific Setup

### Maven Project

```yaml
runcmd:
  # Build project (as user)
  - su - USERNAME -c "cd /home/USERNAME/project && mvn dependency:resolve"
  
  # Or build completely
  - su - USERNAME -c "cd /home/USERNAME/project && mvn package -DskipTests"
```

### Gradle Project

```yaml
runcmd:
  # Download dependencies
  - su - USERNAME -c "cd /home/USERNAME/project && ./gradlew dependencies"
  
  # Or build
  - su - USERNAME -c "cd /home/USERNAME/project && ./gradlew build -x test"
```

### Maven Wrapper (mvnw)

If project includes Maven wrapper:
```yaml
runcmd:
  - su - USERNAME -c "cd /home/USERNAME/project && ./mvnw dependency:resolve"
```

## Verification

```yaml
runcmd:
  # ... installation commands ...
  
  # Verify
  - java -version
  - javac -version
  - mvn -version
  - gradle --version || true  # May not be installed
  - echo "JAVA_HOME=$JAVA_HOME"
```

## Common Configurations

### Spring Boot Development

```yaml
packages:
  - openjdk-21-jdk
  - maven

runcmd:
  # Spring Boot CLI (optional)
  - |
    SPRING_VERSION="3.2.4"
    wget -q "https://repo.maven.apache.org/maven2/org/springframework/boot/spring-boot-cli/${SPRING_VERSION}/spring-boot-cli-${SPRING_VERSION}-bin.tar.gz" -O /tmp/spring.tar.gz
    tar -xzf /tmp/spring.tar.gz -C /opt
    ln -s /opt/spring-${SPRING_VERSION}/bin/spring /usr/local/bin/spring
    rm /tmp/spring.tar.gz
```

### Quarkus Development

```yaml
packages:
  - openjdk-21-jdk
  - maven

runcmd:
  # Quarkus CLI
  - curl -Ls https://sh.jbang.dev | bash -s - trust add https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/
  - curl -Ls https://sh.jbang.dev | bash -s - app install --fresh --force quarkus@quarkusio
```

### Android Development

```yaml
packages:
  - openjdk-17-jdk  # Android uses JDK 17
  - unzip
  - wget

runcmd:
  # Install Android command-line tools
  - |
    mkdir -p /opt/android-sdk/cmdline-tools
    wget -q "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" -O /tmp/cmdline-tools.zip
    unzip -q /tmp/cmdline-tools.zip -d /opt/android-sdk/cmdline-tools
    mv /opt/android-sdk/cmdline-tools/cmdline-tools /opt/android-sdk/cmdline-tools/latest
    rm /tmp/cmdline-tools.zip
    
    # Accept licenses
    yes | /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses
    
    # Install build tools
    /opt/android-sdk/cmdline-tools/latest/bin/sdkmanager "platform-tools" "build-tools;34.0.0"
```

## Environment Variables

Add to user's shell profile or set in cloud-init:

```yaml
write_files:
  - path: /etc/profile.d/java.sh
    content: |
      export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
      export PATH="$JAVA_HOME/bin:$PATH"
      export MAVEN_OPTS="-Xmx2g"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `java` not found | Check JAVA_HOME and PATH |
| Wrong Java version | Use `update-alternatives --config java` |
| Maven memory errors | Set `MAVEN_OPTS="-Xmx2g"` |
| Gradle daemon issues | Run with `--no-daemon` |
| Permission denied | Run project builds as user, not root |
| SSL certificate errors | Install `ca-certificates-java` |
