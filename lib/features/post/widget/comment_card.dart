import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone2/model/comment_model.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment;
  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(comment.profilePic),
                radius: 18,
              ),
              SizedBox(
                width: 18,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'u/${comment.username}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'u/${comment.text}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.reply),
              ),
              Text('reply'),
            ],
          ),
        ],
      ),
    );
  }
}
