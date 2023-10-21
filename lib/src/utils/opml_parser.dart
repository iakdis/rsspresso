import 'package:xml/xml.dart';

class OpmlParser {
  static String _filledString(String ch, int ct) {
    var s = '';
    for (var i = 0; i < ct; i++) {
      s += ch;
    }
    return s;
  }

  static String _encodeXml(dynamic s) {
    if (s == null) {
      return '';
    } else {
      final charMap = {'<': '&lt;', '>': '&gt;', '&': '&amp;', '"': '&quot;'};
      s = s.toString();
      s = s.replaceAll('\u00A0', ' ');
      final escaped = s.replaceAllMapped(
          RegExp('[<>&"]'), (match) => charMap[match.group(0)!]!);
      return escaped;
    }
  }

  static XmlDocument _xmlCompile(String xmltext) {
    return XmlDocument.parse(xmltext);
  }

  static void _xmlGatherAttributes(
      XmlNode adrx, Map<String, dynamic> theTable) {
    if (adrx.attributes.isNotEmpty) {
      for (final att in adrx.attributes) {
        if (att.value.isNotEmpty) {
          theTable[att.name.toString()] = att.value;
        }
      }
    }
  }

  static XmlNode _xmlGetAddress(XmlDocument adrx, String name) {
    return adrx.findAllElements(name).first;
  }

  static Map<String, String> _xmlGetSubValues(XmlNode adrx) {
    final values = <String, String>{};
    for (final child in adrx.children) {
      if (child is XmlElement) {
        final name = _xmlGetNodeNameProp(child);
        if (name.isNotEmpty) {
          final val = child.innerText;
          values[name] = val;
        }
      }
    }
    return values;
  }

  static String _xmlGetNodeNameProp(XmlNode adrx) {
    if (adrx is XmlElement) {
      return adrx.name.local;
    }
    return '';
  }

  static bool _xmlHasSubs(XmlNode adrx) {
    return adrx.children.whereType<XmlElement>().isNotEmpty;
  }

  static Map<String, dynamic> _outlineToJson(XmlNode adrx,
      [String? nameOutlineElement]) {
    final theOutline = <String, dynamic>{};
    nameOutlineElement ??= 'outline';
    _xmlGatherAttributes(adrx, theOutline);
    if (_xmlHasSubs(adrx)) {
      theOutline['subs'] = [];
      adrx.findAllElements(nameOutlineElement).forEach((sub) {
        theOutline['subs'].add(_outlineToJson(sub, nameOutlineElement));
      });
    }
    return theOutline;
  }

  static Map<String, dynamic> opmlParse(String opmltext,
      {bool onlySubs = false}) {
    XmlDocument xstruct;
    try {
      xstruct = _xmlCompile(opmltext);
    } catch (err) {
      print('opmlParse: invalid XML.');
      rethrow;
    }

    final adrhead = _xmlGetAddress(xstruct, 'head');
    final adrbody = _xmlGetAddress(xstruct, 'body');

    if (onlySubs) return _outlineToJson(adrbody);
    final theObject = {
      'opml': {
        'head': _xmlGetSubValues(adrhead),
        'body': _outlineToJson(adrbody),
      }
    };
    return theObject;
  }

  static String opmlStringify(Map<String, dynamic> theOutline) {
    var opmltext = '';
    var indentlevel = 0;

    void add(String s) {
      opmltext += '${_filledString('\t', indentlevel)}$s\n';
    }

    void addSubs(List<Map<String, dynamic>> subs) {
      for (final sub in subs) {
        var atts = '';
        for (final x in sub.keys) {
          if (x != 'subs') {
            atts += ' $x="${_encodeXml(sub[x])}"';
          }
        }
        if (sub['subs'] == null) {
          add('<outline$atts />');
        } else {
          add('<outline$atts >');
          indentlevel++;
          addSubs(sub['subs']);
          indentlevel--;
          add('</outline>');
        }
      }
    }

    add('<?xml version="1.0" encoding="UTF-8"?>');
    add('<opml version="2.0">');
    indentlevel++;
    //do head section
    add('<head>');
    indentlevel++;
    for (final x in theOutline['opml']['head'].keys) {
      add('<$x>${theOutline['opml']['head'][x]}</$x>');
    }
    indentlevel--;
    add('</head>');
    //do body section
    add('<body>');
    indentlevel++;
    addSubs(theOutline['opml']['body']['subs']);
    indentlevel--;
    add('</body>');
    indentlevel--;
    add('</opml>');
    return opmltext;
  }
}
