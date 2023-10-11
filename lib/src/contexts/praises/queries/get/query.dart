import 'package:surpraise_infra/src/contexts/collections.dart';
import 'package:surpraise_infra/src/contexts/praises/dtos/dtos.dart';

import '../../../../../surpraise_infra.dart';

import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';

export 'input.dart';
export 'output.dart';

class GetPraiseQuery implements DataQuery<GetPraiseInput> {
  GetPraiseQuery({
    required this.databaseDatasource,
  });

  final DatabaseDatasource databaseDatasource;

  @override
  Future<Either<QueryError, QueryOutput<PraiseDto>>> call(
      GetPraiseInput input) async {
    final praiseOrError = await databaseDatasource.get(
      GetQuery(
        sourceName: praisesCollection,
        operator: FilterOperator.equalsTo,
        value: input.id,
        fieldName: "id",
        select:
            "*, $communitiesCollection(title), $profilesCollection!praise_praiser_id_fkey(name, tag, id, email)",
        orderBy: const OrderFilter(
          field: "created_at",
        ),
      ),
    );

    if (praiseOrError.failure) {
      return Left(
        QueryError(praiseOrError.errorMessage!),
      );
    } else if (praiseOrError.data == null &&
        (praiseOrError.multiData == null || praiseOrError.multiData!.isEmpty)) {
      return Left(
        QueryError(
          "User not found",
          404,
        ),
      );
    }

    final praise = praiseOrError.multiData![0];
    return Right(
      GetPraiseOutput(
        value: PraiseDto(
          id: praise["id"],
          communityId: praise["community_id"],
          message: praise["message"],
          topic: praise["topic"],
          communityTitle: praise[communitiesCollection]["title"],
          praiser: UserDto(
            tag: praise[profilesCollection]["tag"],
            name: praise[profilesCollection]["name"],
            email: praise[profilesCollection]["email"],
            id: praise[profilesCollection]["id"],
          ),
        ),
      ),
    );
  }
}
