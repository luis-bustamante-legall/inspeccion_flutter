class InspeccionesResponse {
  InspeccionesResponse({
    this.list,
    this.total,
    this.paginaActual,
    this.totalPaginas,
  });

  List<ListElement> list;
  int total;
  int paginaActual;
  int totalPaginas;

  factory InspeccionesResponse.fromJson(Map<String, dynamic> json) => InspeccionesResponse(
    list: List<ListElement>.from(json["list"].map((x) => ListElement.fromJson(x))),
    total: json["total"],
    paginaActual: json["pagina_actual"],
    totalPaginas: json["total_paginas"],
  );

  Map<String, dynamic> toJson() => {
    "list": List<dynamic>.from(list.map((x) => x.toJson())),
    "total": total,
    "pagina_actual": paginaActual,
    "total_paginas": totalPaginas,
  };
}

class ListElement {
  ListElement({
    this.codigoInspeccion,
    this.codigoInspeccionLegall,
    this.contacto,
    this.contratanteNombre,
    this.contratanteRazonSocial,
    this.correo,
    this.direccion,
    this.estado,
    this.fechaProgramada,
    this.id,
    this.idCtMotivo,
    this.idDistrito,
    this.idEmpleadoInspector,
    this.idEstado,
    this.idInspeccion,
    this.idMarca,
    this.idModelo,
    this.idTramite,
    this.idVehiculoAsegurado,
    this.marca,
    this.modelo,
    this.nombreApellido,
    this.numeroTramite,
    this.placa,
    this.usuarioCreacion,
  });

  String codigoInspeccion;
  String codigoInspeccionLegall;
  String contacto;
  String contratanteNombre;
  String contratanteRazonSocial;
  String correo;
  String direccion;
  String estado;
  DateTime fechaProgramada;
  int id;
  String idCtMotivo;
  String idDistrito;
  String idEmpleadoInspector;
  String idEstado;
  int idInspeccion;
  String idMarca;
  String idModelo;
  int idTramite;
  String idVehiculoAsegurado;
  String marca;
  String modelo;
  String nombreApellido;
  String numeroTramite;
  String placa;
  String usuarioCreacion;

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
    codigoInspeccion: json["codigoInspeccion"],
    codigoInspeccionLegall: json["codigoInspeccionLegall"],
    contacto: json["contacto"],
    contratanteNombre: json["contratanteNombre"],
    contratanteRazonSocial: json["contratanteRazonSocial"],
    correo: json["correo"],
    direccion: json["direccion"],
    estado: json["estado"],
    fechaProgramada: DateTime.parse(json["fechaProgramada"]),
    id: json["id"],
    idCtMotivo: json["idCtMotivo"],
    idDistrito: json["idDistrito"],
    idEmpleadoInspector: json["idEmpleadoInspector"],
    idEstado: json["idEstado"],
    idInspeccion: json["idInspeccion"],
    idMarca: json["idMarca"],
    idModelo: json["idModelo"],
    idTramite: json["idTramite"],
    idVehiculoAsegurado: json["idVehiculoAsegurado"],
    marca: json["marca"],
    modelo: json["modelo"],
    nombreApellido: json["nombreApellido"],
    numeroTramite: json["numeroTramite"],
    placa: json["placa"],
    usuarioCreacion: json["usuarioCreacion"],
  );

  Map<String, dynamic> toJson() => {
    "codigoInspeccion": codigoInspeccion,
    "codigoInspeccionLegall": codigoInspeccionLegall,
    "contacto": contacto,
    "contratanteNombre": contratanteNombre,
    "contratanteRazonSocial": contratanteRazonSocial,
    "correo": correo,
    "direccion": direccion,
    "estado": estado,
    "fechaProgramada": fechaProgramada.toIso8601String(),
    "id": id,
    "idCtMotivo": idCtMotivo,
    "idDistrito": idDistrito,
    "idEmpleadoInspector": idEmpleadoInspector,
    "idEstado": idEstado,
    "idInspeccion": idInspeccion,
    "idMarca": idMarca,
    "idModelo": idModelo,
    "idTramite": idTramite,
    "idVehiculoAsegurado": idVehiculoAsegurado,
    "marca": marca,
    "modelo": modelo,
    "nombreApellido": nombreApellido,
    "numeroTramite": numeroTramite,
    "placa": placa,
    "usuarioCreacion": usuarioCreacion,
  };
}
