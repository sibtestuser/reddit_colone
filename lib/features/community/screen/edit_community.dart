import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/Theme/pallete.dart';
import 'package:reddit_clone2/core/common/error_text.dart';
import 'package:reddit_clone2/core/common/loader.dart';
import 'package:reddit_clone2/core/constants/constants.dart';
import 'package:reddit_clone2/core/utils.dart';
import 'package:reddit_clone2/features/community/controller/community_controller.dart';
import 'package:reddit_clone2/model/community_model.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? profileFile;

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        profileFile = File(res.files.first.path!);
      });
    }
  }

  void save(Community community) {
    ref
        .watch(communityControllerProvider.notifier)
        .editCommunity(profileFile: profileFile, bannerFiel: bannerFile, community: community, context: context);
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(ThemeNotifierProvider);
    final isLoading = ref.watch(communityControllerProvider);
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (community) {
            return Scaffold(
              backgroundColor: currentTheme.scaffoldBackgroundColor,
              appBar: AppBar(
                // backgroundColor: Pallete.darkModeAppTheme.colorScheme.surface,
                title: const Text('Edit Community'),
                centerTitle: false,
                actions: [
                  TextButton(
                    onPressed: () => save(community),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              body: isLoading
                  ? const Loader()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: selectBannerImage,
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(10),
                                dashPattern: const [10, 4],
                                strokeCap: StrokeCap.round,
                                color: currentTheme.textTheme.titleLarge!.color!,
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: bannerFile != null
                                      ? Image.file(bannerFile!)
                                      : community.banner.isEmpty || community.banner == Constants.bannerDefault
                                          ? const Center(
                                              child: Icon(
                                                Icons.camera_alt_outlined,
                                                size: 40,
                                              ),
                                            )
                                          : Image.network(community.banner),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: GestureDetector(
                                onTap: selectProfileImage,
                                child: profileFile != null
                                    ? CircleAvatar(
                                        backgroundImage: FileImage(profileFile!),
                                        radius: 32,
                                      )
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(community.avatar),
                                        radius: 32,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            );
          },
          error: (error, errorTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
