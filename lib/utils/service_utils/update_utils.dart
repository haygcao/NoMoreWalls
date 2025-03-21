part of '../service_utils.dart';

extension UpdateUtils on ServiceUtils {
  static Future<void> checkForUpdates(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (!Env.enableUpdateChecker) return;
    final database = ref.read(databaseProvider);
    final checkUpdate = await (database.selectOnly(database.preferencesTable)
          ..addColumns([database.preferencesTable.checkUpdate])
          ..where(database.preferencesTable.id.equals(0)))
        .map((row) => row.read(database.preferencesTable.checkUpdate))
        .getSingleOrNull();

    if (checkUpdate == false) return;
    final packageInfo = await PackageInfo.fromPlatform();

    if (Env.releaseChannel == ReleaseChannel.nightly) {
      final value = await globalDio.getUri(
        Uri.parse(
          "https://api.github.com/repos/KRTirtho/spotube/actions/workflows/spotube-release-binary.yml/runs?status=success&per_page=1",
        ),
        options: Options(
          responseType: ResponseType.json,
        ),
      );

      final buildNum = value.data["workflow_runs"][0]["run_number"] as int;

      if (buildNum <= int.parse(packageInfo.buildNumber) || !context.mounted) {
        return;
      }

      await showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black26,
        builder: (context) {
          return RootAppUpdateDialog.nightly(nightlyBuildNum: buildNum);
        },
      );
    } else {
      final value = await globalDio.getUri(
        Uri.parse(
          "https://api.github.com/repos/KRTirtho/spotube/releases/latest",
        ),
      );
      final tagName = (value.data["tag_name"] as String).replaceAll("v", "");
      final currentVersion = packageInfo.version == "Unknown"
          ? null
          : Version.parse(packageInfo.version);
      final latestVersion =
          tagName == "nightly" ? null : Version.parse(tagName);

      if (currentVersion == null ||
          latestVersion == null ||
          (latestVersion.isPreRelease && !currentVersion.isPreRelease) ||
          (!latestVersion.isPreRelease && currentVersion.isPreRelease)) return;

      if (latestVersion <= currentVersion || !context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black26,
        builder: (context) {
          return RootAppUpdateDialog(version: latestVersion);
        },
      );
    }
  }
}