object Form2: TForm2
  Left = 674
  Top = 424
  Width = 580
  Height = 345
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Crazy Media Converter - by crazysaem - v1.0b'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnResize = FormResize
  DesignSize = (
    564
    309)
  PixelsPerInch = 96
  TextHeight = 13
  object PNGButton1: TPNGButton
    Left = 256
    Top = 179
    Width = 34
    Height = 34
    Hint = 'Convert!'
    ButtonLayout = pbsImageAbove
    ButtonStyle = pbsFlat
    ParentShowHint = False
    ShowHint = True
    OnClick = PNGButton1Click
  end
  object Label1: TLabel
    Left = 200
    Top = 219
    Width = 174
    Height = 13
    Caption = 'Please Wait, Conversion in Progress.'
    Visible = False
  end
  object Label2: TLabel
    Left = 4
    Top = 293
    Width = 247
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'made by crazysaem - visit www.crazysaem.funpic.de'
  end
  object QProgressBar1: TQProgressBar
    Left = 88
    Top = 240
    width = 345
    height = 33
    orientation = boHorizontal
    barKind = bkCylinder
    barLook = blGlass
    roundCorner = True
    backgroundColor = clWhite
    barColor = clLime
    startColor = clLime
    finalColor = clLime
    showInactivePos = False
    invertInactPos = False
    inactivePosColor = clGray
    shaped = True
    shapeColor = clBlack
    blockSize = 0
    spaceSize = 0
    showFullBlock = False
    maximum = 100
    position = 100
    caption = '100%'
    captionAlign = taCenter
    font.Charset = DEFAULT_CHARSET
    font.Color = clWindowText
    font.Height = -11
    font.Name = 'MS Sans Serif'
    font.Style = []
    AutoCaption = False
    AutoHint = False
    ShowPosAsPct = False
  end
  object JvHTListBox1: TJvHTListBox
    Left = 0
    Top = 0
    Width = 564
    Height = 157
    HideSel = False
    Align = alTop
    ColorHighlight = clHighlight
    ColorHighlightText = clHighlightText
    ColorDisabledText = clDefault
    MultiSelect = True
    PopupMenu = PopupMenu1
    TabOrder = 1
    OnKeyDown = JvHTListBox1KeyDown
    Anchors = [akLeft, akTop, akRight, akBottom]
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 48
    Top = 184
    object Delete1: TMenuItem
      Caption = 'Delete'
      OnClick = Delete1Click
    end
  end
end
