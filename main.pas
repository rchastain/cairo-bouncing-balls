
unit Main;

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, LCLType,
  CairoLCL, CairoClasses;

type

  { TForm1 }

  TForm1 = class(TForm)
    CPB: TCairoPaintBox;
    TMR: TIdleTimer;
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TMRTimer(Sender: TObject);
  private
    { Private-Deklarationen }
    FFullScreen: boolean;
    procedure Render;
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

uses
  Ball, Types;

{$R *.lfm}

var
  LBalls: array of TBall;

procedure TForm1.Render;
var
  i, j: integer;
begin

  // Bildschirm löschen.
  with CPB.Context do
  begin
    SetSourceRgb(0.1, 0.1, 0.1);
    Rectangle(0, 0, Width, Height);
    Fill;
  end;

  // Rendern der Einzelkugeln.
  for i := 0 to High(LBalls) do
    LBalls[i].Render(CPB);

  // Neuzeichnen des Formulars.
  CPB.Invalidate;

  // Bewegen der einzelnen Kugeln.
  for i := 0 to High(LBalls) do
    LBalls[i].Move;

  // Kollision der Kugeln untereinander.
  for i := 0 to High(LBalls) do
    for j := i + 1 to High(LBalls) do
      LBalls[i].Collision(LBalls[j]);

  // Collision mit den Wänden.
  for i := 0 to High(LBalls) do
    LBalls[i].BorderCollision(ClientRect);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  i: integer;
  LPoint: TPointF;
begin
  case Key of
    VK_ESCAPE: Close;
    VK_ADD:
      for i := 0 to High(LBalls) do
        if Assigned(LBalls[i]) then
        begin
          LPoint := LBalls[i].SpeedVektor;
          LPoint.x := LPoint.x * 2;
          LPoint.y := LPoint.y * 2;
          LBalls[i].SpeedVektor := LPoint;
        end;
    VK_SUBTRACT:
      for i := 0 to High(LBalls) do
        if Assigned(LBalls[i]) then
        begin
          LPoint := LBalls[i].SpeedVektor;
          LPoint.x := LPoint.x / 2;
          LPoint.y := LPoint.y / 2;
          LBalls[i].SpeedVektor := LPoint;
        end;
  end;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  TMR.Enabled := TRUE;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i, w, h: integer;
begin
  Randomize;

  FFullScreen := FALSE;
  if ParamCount > 0 then
    for i := 1 to ParamCount do
      if LowerCase(ParamStr(i)) = '-f' then
        FFullscreen := TRUE;

  if FFullScreen then
  begin
    Top := 0;
    Left := 0;
    Width := Screen.Width;
    Height := Screen.Height;
    BorderStyle := bsNone;
  end;

  CPB.Left := 0;
  CPB.Top := 0;
  CPB.Width := ClientWidth;
  CPB.Height := ClientHeight;

  SetLength(LBalls, 10);
  for i := 0 to High(LBalls) do
  begin
    LBalls[i] := TBall.Create(PointF(0, 0), PointF(0, 0), 20 + Random(40), 0);
    LBalls[i].CalculateMass;
  end;
  w := Width div 5;
  h := Height div 4;
  LBalls[0].position := PointF(w, h * 2);
  LBalls[1].Position := PointF(w * 2, h);
  LBalls[2].Position := PointF(w * 3, h);
  LBalls[3].Position := PointF(w * 4, h);
  LBalls[4].Position := PointF(w * 2, h * 2);
  LBalls[5].Position := PointF(w * 3, h * 2);
  LBalls[6].Position := PointF(w * 4, h * 2);
  LBalls[7].Position := PointF(w * 2, h * 3);
  LBalls[8].Position := PointF(w * 3, h * 3);
  LBalls[9].Position := PointF(w * 4, h * 3);
  // Die Richtung für unseren StarBall setzen
  LBalls[0].SpeedVektor := PointF(Cos(-45 * PI / 180) * 4, Sin(-45 * PI / 180) * 4);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: integer;
begin
  for i := 0 to High(LBalls) do
    LBalls[i].Free;
end;

procedure TForm1.TMRTimer(Sender: TObject);
begin
  Render;
end;

end.

