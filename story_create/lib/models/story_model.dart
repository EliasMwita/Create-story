import 'package:hive/hive.dart';

part 'story_model.g.dart';

@HiveType(typeId: 0)
class StoryModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  String mood;
  
  @HiveField(4)
  String place;
  
  @HiveField(5)
  DateTime date;
  
  @HiveField(6)
  List<String> imagePaths;
  
  @HiveField(7)
  String? musicPath;
  
  @HiveField(8)
  String? videoOutputPath;
  
  @HiveField(9)
  List<String>? captions;
  
  @HiveField(10)
  String? templateId;
  
  StoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.mood,
    required this.place,
    required this.date,
    required this.imagePaths,
    this.musicPath,
    this.videoOutputPath,
    this.captions,
    this.templateId,
  });
  
  StoryModel.create({
    required this.title,
    required this.description,
    required this.mood,
    required this.place,
    required this.imagePaths,
    this.musicPath,
    this.captions,
    this.templateId,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(),
       date = DateTime.now();
  
  StoryModel copyWith({
    String? id,
    String? title,
    String? description,
    String? mood,
    String? place,
    DateTime? date,
    List<String>? imagePaths,
    String? musicPath,
    String? videoOutputPath,
    List<String>? captions,
    String? templateId,
  }) {
    return StoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      mood: mood ?? this.mood,
      place: place ?? this.place,
      date: date ?? this.date,
      imagePaths: imagePaths ?? this.imagePaths,
      musicPath: musicPath ?? this.musicPath,
      videoOutputPath: videoOutputPath ?? this.videoOutputPath,
      captions: captions ?? this.captions,
      templateId: templateId ?? this.templateId,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'mood': mood,
      'place': place,
      'date': date.toIso8601String(),
      'imagePaths': imagePaths,
      'musicPath': musicPath,
      'videoOutputPath': videoOutputPath,
      'captions': captions,
      'templateId': templateId,
    };
  }
  
  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      mood: json['mood'],
      place: json['place'],
      date: DateTime.parse(json['date']),
      imagePaths: List<String>.from(json['imagePaths']),
      musicPath: json['musicPath'],
      videoOutputPath: json['videoOutputPath'],
      captions: json['captions'] != null 
          ? List<String>.from(json['captions'])
          : null,
      templateId: json['templateId'],
    );
  }
  
  @override
  String toString() {
    return 'StoryModel(id: $id, title: $title, date: $date)';
  }
}

// Run this command to generate the adapter:
// flutter packages pub run build_runner build