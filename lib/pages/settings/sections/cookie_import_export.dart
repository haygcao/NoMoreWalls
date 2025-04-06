import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/modules/settings/section_card_with_heading.dart';
import 'package:spotube/provider/spotify/authentication.dart';
import 'package:spotube/provider/youtube_music/auth_provider.dart';
import 'package:spotube/provider/scrobbler/scrobbler.dart';
import 'package:spotube/services/cookie/cookie_manager.dart';

class CookieImportExportSection extends HookConsumerWidget {
  const CookieImportExportSection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);
    final cookieManager = CookieManager();
    final spotifyAuthNotifier = ref.read(spotifyAuthenticationProvider.notifier);
    final youtubeAuthNotifier = ref.read(youtubeMusicAuthProvider.notifier);
    final scrobblerNotifier = ref.read(scrobblerProvider.notifier);

    // 导出 Cookie 函数
    Future<void> exportCookies() async {
      try {
        final Map<String, dynamic> cookiesData = {};
        
        // 获取 Spotify Cookie
        final spotifyCookies = await cookieManager.getCookies('spotify');
        if (spotifyCookies != null && spotifyCookies.isNotEmpty) {
          cookiesData['spotify'] = spotifyCookies;
        }
        
        // 获取 YouTube Music Cookie
        final youtubeMusicCookies = await cookieManager.getCookies('youtube_music');
        if (youtubeMusicCookies != null && youtubeMusicCookies.isNotEmpty) {
          cookiesData['youtube_music'] = youtubeMusicCookies;
        }
        
        if (cookiesData.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('no_accounts_connected')),
          );
          return;
        }
        
        // 保存为文件
        final String jsonData = jsonEncode(cookiesData);
        final String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: '导出 Cookie',
          fileName: 'spotube_cookies.json',
          allowedExtensions: ['json'],
        );
        
        if (outputPath != null) {
          final file = File(outputPath);
          await file.writeAsString(jsonData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cookie 导出成功')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('错误: $e')),
        );
      }
    }
    
    // 导入 Cookie 函数
    Future<void> importCookies() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        
        if (result != null && result.files.single.path != null) {
          final file = File(result.files.single.path!);
          final jsonData = await file.readAsString();
          final Map<String, dynamic> cookiesData = jsonDecode(jsonData);
          
          // 导入 Spotify Cookie
          if (cookiesData.containsKey('spotify')) {
            final spotifyCookies = Map<String, String>.from(cookiesData['spotify']);
            await cookieManager.saveCookies('spotify', spotifyCookies);
            
            // 如果有 sp_dc cookie，则登录 Spotify
            if (spotifyCookies.containsKey('sp_dc')) {
              final cookieHeader = "sp_dc=${spotifyCookies['sp_dc']}";
              await spotifyAuthNotifier.login(cookieHeader);
            }
          }
          
          // 导入 YouTube Music Cookie
          if (cookiesData.containsKey('youtube_music')) {
            final youtubeMusicCookies = Map<String, String>.from(cookiesData['youtube_music']);
            await cookieManager.saveCookies('youtube_music', youtubeMusicCookies);
            await youtubeAuthNotifier.login(youtubeMusicCookies);
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cookie 导入成功')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('错误: $e')),
        );
      }
    }

    return SectionCardWithHeading(
      heading: '账户数据',
      children: [
        const ListTile(
          leading: Icon(Icons.import_export),
          title: Text('导入/导出 Cookie'),
          subtitle: Text('备份或恢复您的账户登录状态'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: importCookies,
                icon: const Icon(Icons.upload_file),
                label: const Text('导入'),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: exportCookies,
                icon: const Icon(Icons.download),
                label: const Text('导出'),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}