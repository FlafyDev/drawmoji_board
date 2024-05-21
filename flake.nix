{
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/25865a40d14b3f9cf19f19b924e2ab4069b09588";

    nixpkgs.url = "github:nixos/nixpkgs/cf8cc1201be8bc71b7cbbbdaf349b22f4f99c7ae";

    flake-parts = {
      url = "github:hercules-ci/flake-parts/9126214d0a59633752a136528f5f3b9aa8565b7d";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      perSystem = {
        pkgs,
        system,
        lib,
        ...
      }: {
        devShells.default = let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              android_sdk.accept_license = true;
            };
          };
          buildToolsVersionForAapt2 = "34.0.0";
          androidComposition = pkgs.androidenv.composeAndroidPackages {
            # Installing both version for aapt2 and version that flutter wants
            buildToolsVersions = [buildToolsVersionForAapt2 "30.0.3"];
            platformVersions = ["34" "33" "31" "30"];
            abiVersions = ["armeabi-v7a" "arm64-v8a" "x86" "x86_64"];
            toolsVersion = "26.1.1";
            platformToolsVersion = "33.0.3";
            extraLicenses = [
              "android-googletv-license"
              "android-sdk-arm-dbt-license"
              "android-sdk-license"
              "android-sdk-preview-license"
              "google-gdk-license"
              "intel-android-extra-license"
              "intel-android-sysimage-license"
              "mips-android-sysimage-license"
            ];
          };
          androidSdk = androidComposition.androidsdk;
        in
          pkgs.mkShell {
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${buildToolsVersionForAapt2}/aapt2";
            nativeBuildInputs = with pkgs; [
              jdk11
              androidSdk
              android-tools

              pkg-config
              flutter
              inotify-tools
              lsof
            ];
            buildInputs = with pkgs; [
              gtk-layer-shell
              cava
            ];
          };
        formatter = pkgs.alejandra;
      };
    };
}
