import 'package:flutter/cupertino.dart';
import 'package:flutter_proj/database/database_games.dart';
import 'package:flutter_proj/model/echipa.dart';
import 'package:flutter_proj/model/meci.dart';
import 'package:flutter_proj/model/mecidto.dart';

class Service extends ChangeNotifier {
  final IEchipaDBRepo _echipaRepo;
  final IMeciDBRepo _meciRepo;
  Service(this._echipaRepo, this._meciRepo);

  Future<List<Meci>> getAllMeciuri() async {
    return await _meciRepo.getAllElements();
  }

  Future<List<Echipa>> getAllEchipe() async {
    return await _echipaRepo.getAllElements();
  }

  Future addEchipa(int nrpuncte, String nume, String imageUrl, String stadion,
      String detinator) async {
    await _echipaRepo
        .addElement(Echipa(-1, nrpuncte, nume, imageUrl, stadion, detinator));
    notifyListeners();
  }

  Future<Meci> findMeci(String Echipa1, String Echipa2) async {
    List<Meci> meciuri = [];
    for (var a in await _meciRepo.getAllElements()) {
      if (a.Echipa1 == Echipa1 && a.Echipa2 == Echipa2) {
        return a;
      }
    }
    if (meciuri.isNotEmpty) {
      return meciuri[0];
    } else {
      meciuri.insert(0, new Meci(-123, "ceva", "ceva", 1, 1));
      return meciuri[0];
    }
  }

  Future editMeci(
      int id, String Echipa1, String Echipa2, int goluri1, int goluri2) async {
    var a = await _echipaRepo.getEchipaByName(Echipa1);
    var b = await _echipaRepo.getEchipaByName(Echipa2);
    var c = await findMeci(Echipa1, Echipa2);
    if (goluri1 == goluri2 && c.goluri1 < c.goluri2) {
      b?.nrpuncte -= 2;
      a?.nrpuncte += 1;
    } else if (goluri1 == goluri2 && c.goluri1 > c.goluri2) {
      a?.nrpuncte -= 2;
      b?.nrpuncte += 1;
    } else if (goluri1 > goluri2 && c.goluri1 == c.goluri2) {
      a?.nrpuncte += 2;
      b?.nrpuncte -= 1;
    } else if (goluri1 < goluri2 && c.goluri1 == c.goluri2) {
      b?.nrpuncte += 2;
      a?.nrpuncte -= 1;
    } else if (goluri1 < goluri2 && c.goluri1 > c.goluri2) {
      a?.nrpuncte -= 3;
      b?.nrpuncte += 3;
    } else if (goluri1 > goluri2 && c.goluri1 < c.goluri2) {
      b?.nrpuncte -= 3;
      a?.nrpuncte += 3;
    }
    await _meciRepo.editElement(Meci(id, Echipa1, Echipa2, goluri1, goluri2));
    await _echipaRepo.editElement(a!);
    await _echipaRepo.editElement(b!);
    notifyListeners();
  }

  Future addMeci(
      String Echipa1, String Echipa2, int goluri1, int goluri2) async {
    var a = await _echipaRepo.getEchipaByName(Echipa1);
    var b = await _echipaRepo.getEchipaByName(Echipa2);
    var c = await findMeci(Echipa1, Echipa2);
    if (c.id == -123) {
      if (goluri1 < goluri2) {
        b?.nrpuncte += 3;
      } else if (goluri1 > goluri2) {
        a?.nrpuncte += 3;
      } else if (goluri1 == goluri2) {
        a?.nrpuncte += 1;
        b?.nrpuncte += 1;
      }
      if (a?.nume == Echipa1 && b?.nume == Echipa2) {
        await _meciRepo
            .addElement(Meci(-1, Echipa1, Echipa2, goluri1, goluri2));
        await _echipaRepo.editElement(a!);
        await _echipaRepo.editElement(b!);
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } else {
      editMeci(c.id, Echipa1, Echipa2, goluri1, goluri2);
      return true;
    }
  }

  Future deleteMeci(int id) async {
    var c = await _meciRepo.getOneElement(id);
    var a = await _echipaRepo.getEchipaByName(c.Echipa1);
    var b = await _echipaRepo.getEchipaByName(c.Echipa2);
    if (c.goluri1 < c.goluri2) {
      b?.nrpuncte -= 3;
    } else if (c.goluri1 > c.goluri2) {
      a?.nrpuncte -= 3;
    } else if (c.goluri1 == c.goluri2) {
      a?.nrpuncte -= 1;
      b?.nrpuncte -= 1;
    }
    await _echipaRepo.editElement(a!);
    await _echipaRepo.editElement(b!);
    await _meciRepo.deleteElement(id);
    notifyListeners();
  }

  Future<Echipa?> getEchipaByName(String name) async {
    return await _echipaRepo.getEchipaByName(name);
  }

  Future<List<MeciDTO>> getAllMeciuriDTO() async {
    var meciuri = await _meciRepo.getAllElements();
    List<MeciDTO> list = [];
    for (var meci in meciuri) {
      var c = await getEchipaByName(meci.Echipa1);
      var d = await getEchipaByName(meci.Echipa2);
      list.add(MeciDTO(meci.id, meci.Echipa1, meci.Echipa2, c!.imageUrl,
          d!.imageUrl, meci.goluri1, meci.goluri2));
    }
    return list;
  }
}
