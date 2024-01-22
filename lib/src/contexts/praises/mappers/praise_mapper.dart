import 'package:surpraise_core/surpraise_core.dart';

abstract class PraiseMapper {
  static Map<String, dynamic> inputToMap(PraiseInput input) => {
        "id": input.id,
        "praised_id": input.praisedId,
        "praiser_id": input.praiserId,
        "message": input.message,
        "private": input.private,
        "community_id": input.commmunityId,
        "topic": input.topic,
        "created_at": DateTime.now().toIso8601String(),
        "extra_praiseds": input.extraPraisedIds
      };
}
