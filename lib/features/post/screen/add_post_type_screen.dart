import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/Theme/pallete.dart';
import 'package:reddit_clone2/core/common/error_text.dart';
import 'package:reddit_clone2/core/common/loader.dart';
import 'package:reddit_clone2/core/utils.dart';
import 'package:reddit_clone2/features/community/controller/community_controller.dart';
import 'package:reddit_clone2/features/post/controller/post_controller.dart';
import 'package:reddit_clone2/model/community_model.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({super.key, required this.type});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  File? bannerFile;
  List<Community> communities = [];
  Community? selectedCommunity;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (widget.type == 'image' && bannerFile != null && titleController.text.isNotEmpty) {
      ref.read(PostControllerProvider.notifier).sharedImagePost(
          context: context,
          title: titleController.text.trim(),
          selectedCommunity: selectedCommunity ?? communities[0],
          file: bannerFile);
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(PostControllerProvider.notifier).sharedTextPost(
          context: context,
          title: titleController.text.trimLeft(),
          selectedCommunity: selectedCommunity ?? communities[0],
          description: descriptionController.text.trim());
    } else if (widget.type == 'link' && titleController.text.isNotEmpty && linkController.text.isNotEmpty) {
      ref.read(PostControllerProvider.notifier).sharedLinkPost(
          context: context,
          title: titleController.text.trimLeft(),
          selectedCommunity: selectedCommunity ?? communities[0],
          link: linkController.text.trim());
    } else {
      showSnackBar(context, '내용을 입력해 주세요');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(ThemeNotifierProvider);
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';
    final isLoadint = ref.watch(PostControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Post ${widget.type} '),
        actions: [
          TextButton(
            onPressed: sharePost,
            child: const Text('Share'),
          ),
        ],
      ),
      body: isLoadint
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    maxLines: 1,
                    maxLength: 30,
                    decoration: const InputDecoration(
                        filled: true,
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.all(18),
                        hintText: 'Enter Title here'),
                  ),
                  const SizedBox(height: 10),
                  if (isTypeImage)
                    GestureDetector(
                      onTap: selectBannerImage,
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(10),
                        dashPattern: const [10, 4],
                        strokeCap: StrokeCap.round,
                        color: Pallete.darkModeAppTheme.hintColor,
                        child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: bannerFile != null
                                ? Image.file(bannerFile!)
                                : const Center(
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 40,
                                    ),
                                  )),
                      ),
                    ),
                  if (isTypeText)
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        filled: true,
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.all(18),
                        hintText: 'Enter Description here',
                      ),
                      maxLines: 5,
                    ),
                  if (isTypeLink)
                    TextField(
                      controller: linkController,
                      decoration: const InputDecoration(
                          filled: true,
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          alignLabelWithHint: true,
                          contentPadding: EdgeInsets.all(18),
                          hintText: 'Enter Link Here'),
                    ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Select Community'),
                  ),
                  ref.watch(userCommunitiesProvider).when(
                        data: (data) {
                          communities = data;
                          if (data.isEmpty) {
                            return const SizedBox();
                          }
                          return DropdownButton(
                            value: selectedCommunity ?? data[0],
                            items: data.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedCommunity = val;
                              });
                            },
                          );
                        },
                        error: (error, trace) => ErrorText(error: error.toString()),
                        loading: () => const Loader(),
                      ),
                ],
              ),
            ),
    );
  }
}
