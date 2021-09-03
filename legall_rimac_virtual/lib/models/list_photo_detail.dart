class ListPhotoDetail {
  List<PhotoDetail> listPhotoDetail;

  ListPhotoDetail({this.listPhotoDetail});

  factory ListPhotoDetail.fromJson(dynamic json) =>
      ListPhotoDetail(
        listPhotoDetail: List<PhotoDetail>.from(
          json.map((x) => PhotoDetail.fromJson(x)),
        ),
      );
}

class PhotoDetail {
  PhotoDetail({
    this.descripcion,
    this.id,
    this.orden,
    this.requerido,
  });

  String descripcion;
  int id;
  int orden;
  bool requerido;

  factory PhotoDetail.fromJson(Map<String, dynamic> json) => PhotoDetail(
    descripcion: json["descripcion"],
    id: json["id"],
    orden: json["orden"],
    requerido: json["requerido"],
  );

  Map<String, dynamic> toJson() => {
    "descripcion": descripcion,
    "id": id,
    "orden": orden,
    "requerido": requerido,
  };
}
