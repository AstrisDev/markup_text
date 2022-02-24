library markup_text;

import 'dart:ui' as ui show PlaceholderAlignment;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:markup_text/src/markup_parser.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkupText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final TextStyle? style;

  const MarkupText(
    this.text, {
    Key? key,
    this.textAlign = TextAlign.left,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TextPart> partList = [];
    String current = "";
    List<TextType> currentTypes = [];
    String? cUrl;
    String? cColor;

    addPart() {
      if (current != "") {
        partList.add(
          TextPart(current, url: cUrl, color: cColor)..addAll(currentTypes),
        );
        current = "";
      }
    }

    addIconPart(String code, double size, String color) {
      partList.add(
        TextPart(
          "",
          icon: code,
          iconSize: size,
          color: color,
        )..add(TextType.icon),
      );
    }

    addType(TextType t) {
      if (!currentTypes.contains(t)) currentTypes.add(t);
    }

    removeType(TextType t) {
      if (currentTypes.contains(t)) currentTypes.remove(t);
    }

    for (int pointer = 0; pointer < text.length; pointer++) {
      if (text[pointer] == "(") {
        int end = text.indexOf(")", pointer);
        if (end > 0) {
          String code = text.substring(pointer + 1, end);
          switch (code) {
            case "b":
              addPart();
              addType(TextType.bold);
              pointer += 2;
              break;
            case "i":
              addPart();
              addType(TextType.italic);
              pointer += 2;
              break;
            case "u":
              addPart();
              addType(TextType.underlined);
              pointer += 2;
              break;
            case "/b":
              addPart();
              removeType(TextType.bold);
              pointer += 3;
              break;
            case "/i":
              addPart();
              removeType(TextType.italic);
              pointer += 3;
              break;
            case "/u":
              addPart();
              removeType(TextType.underlined);
              pointer += 3;
              break;
            case "/u":
              addPart();
              removeType(TextType.underlined);
              pointer += 3;
              break;
            case "/a":
              addPart();
              removeType(TextType.link);
              cUrl = null;
              pointer += 3;
              break;
            case "/c":
              addPart();
              removeType(TextType.color);
              cColor = null;
              pointer += 3;
              break;
            default:
              if (code.startsWith("a ")) {
                addPart();
                addType(TextType.link);
                cUrl = code.substring(2);
                pointer += code.length + 1;
                break;
              }
              if (code.startsWith("c ")) {
                addPart();
                addType(TextType.color);
                cColor = code.substring(2);
                pointer += code.length + 1;
                break;
              }
              if (code.startsWith("icon ")) {
                addPart();
                addIconPart(
                  code.substring(5),
                  style?.fontSize ?? 14,
                  cColor ?? 'black',
                );
                pointer += code.length + 1;
                break;
              }
              current += text[pointer];
          }
        } else
          current += text[pointer];
      } else
        current += text[pointer];
    }
    addPart();

    return RichText(
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
      text: TextSpan(
          style: DefaultTextStyle.of(context).style.merge(style),
          children: partList.map((e) => e.toSpan()).toList()),
    );
  }
}

enum TextType { link, bold, italic, underlined, color, icon }

class TextPart {
  final String text;
  final String? url;
  final String? color;
  final String? icon;
  final double? iconSize;
  final List<TextType> types = [];

  TextPart(
    this.text, {
    this.url,
    this.color,
    this.icon,
    this.iconSize,
  });

  add(TextType type) {
    types.add(type);
  }

  addAll(List<TextType> currentTypes) {
    for (TextType type in currentTypes) types.add(type);
  }

  InlineSpan toSpan() {
    Color? cColor;
    TapGestureRecognizer? recognizer;
    List<TextDecoration> decorations = [];
    FontWeight fontWeight = FontWeight.normal;
    FontStyle fontStyle = FontStyle.normal;

    for (TextType type in types) {
      switch (type) {
        case TextType.link:
          cColor = Colors.blue;
          decorations.add(TextDecoration.underline);
          if (url != null)
            recognizer = TapGestureRecognizer()
              ..onTap = () async {
                if (await canLaunch(url!)) launch(url!);
              };
          break;
        case TextType.color:
          if (color != null) {
            if (color!.startsWith("#"))
              cColor = MarkupParser.hexToColor(color!);
            else
              cColor = MarkupParser.nameToColor(color!);
          } else {
            cColor = MarkupParser.nameToColor('white');
          }

          break;
        case TextType.bold:
          fontWeight = FontWeight.bold;
          break;
        case TextType.italic:
          fontStyle = FontStyle.italic;
          break;
        case TextType.underlined:
          decorations.add(TextDecoration.underline);
          break;
        case TextType.icon:
          IconData? iconData = MarkupParser.getIconData(icon!);

          if (color != null) {
            if (color!.startsWith("#"))
              cColor = MarkupParser.hexToColor(color!);
            else
              cColor = MarkupParser.nameToColor(color!);
          }

          if (iconData != null) {
            return WidgetSpan(
              alignment: ui.PlaceholderAlignment.middle,
              child: Icon(iconData,
                  textDirection: TextDirection.ltr,
                  size: iconSize,
                  color: cColor),
            );
          }
      }
    }
    return TextSpan(
      text: this.text,
      recognizer: recognizer,
      style: TextStyle(
        fontStyle: fontStyle,
        fontWeight: fontWeight,
        color: cColor,
        decoration: TextDecoration.combine(decorations),
      ),
    );
  }
}
