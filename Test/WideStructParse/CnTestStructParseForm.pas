unit CnTestStructParseForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, TypInfo;

type
  TTeststructParseForm = class(TForm)
    pgc1: TPageControl;
    tsPascal: TTabSheet;
    tsCpp: TTabSheet;
    mmoPasSrc: TMemo;
    btnParsePas: TButton;
    mmoPasResult: TMemo;
    mmoCppSrc: TMemo;
    btnParseCpp: TButton;
    mmoCppResult: TMemo;
    btnGetUses: TButton;
    lblPascal: TLabel;
    lblCpp: TLabel;
    chkWidePas: TCheckBox;
    chkWideCpp: TCheckBox;
    procedure btnParsePasClick(Sender: TObject);
    procedure mmoPasSrcChange(Sender: TObject);
    procedure btnGetUsesClick(Sender: TObject);
    procedure mmoCppSrcChange(Sender: TObject);
    procedure btnParseCppClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mmoPasSrcClick(Sender: TObject);
    procedure mmoCppSrcClick(Sender: TObject);
  private
    { Private declarations }
    procedure ShowCursorPos;
  public
    { Public declarations }
  end;

var
  TeststructParseForm: TTeststructParseForm;

implementation

uses CnWidePasParser, mPasLex, CnWideCppParser, mwBCBTokenList;

{$R *.dfm}

procedure TTeststructParseForm.btnGetUsesClick(Sender: TObject);
var
  List: TStrings;
begin
  List := TStringList.Create;

  try
    ParseUnitUsesW(mmoPasSrc.Lines.Text, List, chkWidePas.Checked);
    ShowMessage(List.Text);
  finally
    List.Free;
  end;
end;

procedure TTeststructParseForm.btnParseCppClick(Sender: TObject);
var
  Parser: TCnWideCppStructParser;
  S: WideString;
  I: Integer;
  Token: TCnWideCppToken;
begin
  mmoCppResult.Lines.Clear;
  Parser := TCnWideCppStructParser.Create(chkWideCpp.Checked);

  try
    S := mmoCppSrc.Lines.Text;
    Parser.ParseSource(PWideChar(S), Length(S), mmoCppSrc.CaretPos.Y + 1,
      mmoCppSrc.CaretPos.X + 1, True);

    for I := 0 to Parser.Count - 1 do
    begin
      Token := Parser.Tokens[I];
      mmoCppResult.Lines.Add(Format('%3.3d Token. Line: %d, Col %2.2d, Position %4.4d. TokenKind %s, Token: %s',
        [I, Token.LineNumber, Token.CharIndex, Token.TokenPos, GetEnumName(TypeInfo(TCTokenKind),
         Ord(Token.CppTokenKind)), Token.Token]));
    end;
    mmoCppResult.Lines.Add('');

    if Parser.BlockStartToken <> nil then
      mmoCppResult.Lines.Add(Format('OuterStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockStartToken.LineNumber, Parser.BlockStartToken.CharIndex,
        Parser.BlockStartToken.ItemLayer, Parser.BlockStartToken.Token]));
    if Parser.BlockCloseToken <> nil then
      mmoCppResult.Lines.Add(Format('OuterClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockCloseToken.LineNumber, Parser.BlockCloseToken.CharIndex,
        Parser.BlockCloseToken.ItemLayer, Parser.BlockCloseToken.Token]));
    if Parser.BlockIsNamespace then
      mmoCppResult.Lines.Add('Outer is namespace.')
    else
      mmoCppResult.Lines.Add('Outer is NOT namespace.');

    if Parser.ChildStartToken <> nil then
      mmoCppResult.Lines.Add(Format('ChildStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.ChildStartToken.LineNumber, Parser.ChildStartToken.CharIndex,
        Parser.ChildStartToken.ItemLayer, Parser.ChildStartToken.Token]));
    if Parser.ChildCloseToken <> nil then
      mmoCppResult.Lines.Add(Format('ChildClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.ChildCloseToken.LineNumber, Parser.ChildCloseToken.CharIndex,
        Parser.ChildCloseToken.ItemLayer, Parser.ChildCloseToken.Token]));

    if Parser.InnerBlockStartToken <> nil then
      mmoCppResult.Lines.Add(Format('InnerStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockStartToken.LineNumber, Parser.InnerBlockStartToken.CharIndex,
        Parser.InnerBlockStartToken.ItemLayer, Parser.InnerBlockStartToken.Token]));
    if Parser.InnerBlockCloseToken <> nil then
      mmoCppResult.Lines.Add(Format('InnerClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockCloseToken.LineNumber, Parser.InnerBlockCloseToken.CharIndex,
        Parser.InnerBlockCloseToken.ItemLayer, Parser.InnerBlockCloseToken.Token]));
  finally
    Parser.Free;
  end;
end;

procedure TTeststructParseForm.btnParsePasClick(Sender: TObject);
var
  Parser: TCnWidePasStructParser;
  S: WideString;
  I: Integer;
  Token: TCnWidePasToken;
begin
  mmoPasResult.Lines.Clear;
  Parser := TCnWidePasStructParser.Create(chkWidePas.Checked);

  S := mmoPasSrc.Lines.Text;
  try
    Parser.ParseSource(PWideChar(S), False, False);
    Parser.FindCurrentBlock(mmoPasSrc.CaretPos.Y + 1, mmoPasSrc.CaretPos.X + 1);

    for I := 0 to Parser.Count - 1 do
    begin
      Token := Parser.Tokens[I];
      mmoPasResult.Lines.Add(Format('%3.3d Token. Line: %d, Col %2.2d, Position %4.4d. TokenKind %s, Token: %s',
        [I, Token.LineNumber, Token.CharIndex, Token.TokenPos, GetEnumName(TypeInfo(TTokenKind), Ord(Token.TokenID)), Token.Token]
      ));
    end;
    mmoPasResult.Lines.Add('');

    if Parser.BlockStartToken <> nil then
      mmoPasResult.Lines.Add(Format('OuterStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockStartToken.LineNumber, Parser.BlockStartToken.CharIndex,
        Parser.BlockStartToken.ItemLayer, Parser.BlockStartToken.Token]));
    if Parser.BlockCloseToken <> nil then
      mmoPasResult.Lines.Add(Format('OuterClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.BlockCloseToken.LineNumber, Parser.BlockCloseToken.CharIndex,
        Parser.BlockCloseToken.ItemLayer, Parser.BlockCloseToken.Token]));
    if Parser.InnerBlockStartToken <> nil then
      mmoPasResult.Lines.Add(Format('InnerStart: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockStartToken.LineNumber, Parser.InnerBlockStartToken.CharIndex,
        Parser.InnerBlockStartToken.ItemLayer, Parser.InnerBlockStartToken.Token]));
    if Parser.InnerBlockCloseToken <> nil then
      mmoPasResult.Lines.Add(Format('InnerClose: Line: %d, Col %2.2d. Layer: %d. Token: %s',
       [Parser.InnerBlockCloseToken.LineNumber, Parser.InnerBlockCloseToken.CharIndex,
        Parser.InnerBlockCloseToken.ItemLayer, Parser.InnerBlockCloseToken.Token]));
  finally
    Parser.Free;
  end;
end;

procedure TTeststructParseForm.FormCreate(Sender: TObject);
begin
  ShowCursorPos;
end;

procedure TTeststructParseForm.mmoCppSrcChange(Sender: TObject);
begin
  ShowCursorPos;
end;

procedure TTeststructParseForm.mmoCppSrcClick(Sender: TObject);
begin
  ShowCursorPos;
end;

procedure TTeststructParseForm.mmoPasSrcChange(Sender: TObject);
begin
  ShowCursorPos;
end;

procedure TTeststructParseForm.mmoPasSrcClick(Sender: TObject);
begin
  ShowCursorPos;
end;

procedure TTeststructParseForm.ShowCursorPos;
begin
  lblPascal.Caption := Format('Line: %d, Col %d.', [mmoPasSrc.CaretPos.Y + 1,
    mmoPasSrc.CaretPos.X + 1]);
  lblCpp.Caption := Format('Line: %d, Col %d.', [mmoCppSrc.CaretPos.Y + 1,
    mmoCppSrc.CaretPos.X + 1]);
end;

end.
