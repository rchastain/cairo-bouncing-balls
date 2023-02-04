
unit Ball;

interface

uses
  Classes, Types, Graphics, CairoLCL, CairoClasses;

type
  TCairoColor = record
    r, g, b: double;
  end;

  TBall = class
  private
    FVecX, FVecY, FX, FY, FRadius, FMass: single;
    FColor: TCairoColor;
    function GetPos: TPointF;
    procedure SetPos(APos: TPointF);
    function GetSpeed: TPointF;
    procedure SetSpeed(ASpeed: TPointF);
  public
    property Color: TCairoColor read FColor write FColor;
    property Radius: single read FRadius;
    property Position: TPointF read GetPos write SetPos;
    property SpeedVektor: TPointF read GetSpeed write SetSpeed;
    property Mass: single read FMass write FMass;
    constructor Create(Position, SpeedVektor: TPointF; Radius, Mass: single);
    destructor Destroy; override;
    procedure Render(const APaintBox: TCairoPaintBox);
    procedure CalculateMass;
    procedure BorderCollision(CollisionRect: TRect; InsideCollision: boolean = TRUE);
    procedure Collision(const ABall: TBall);
    procedure Move;
  end;

function PointF(x, y: single): TPointF;

implementation

uses
  Geometry;

function PointF(x, y: single): TPointF;
begin
  result.x := x;
  result.y := y;
end;

constructor TBall.Create(Position, SpeedVektor: TPointF; Radius, Mass: single);

  function RandomColor: TCairoColor;
  begin
    result.r := (Random(64) +  64) / 255;
    result.g := (Random(64) +  64) / 255;
    result.b := (Random(64) + 192) / 255;
  end;

begin
  inherited Create;
  FColor := RandomColor; // Zufällige Farbe für unsere Kugel.
  FX := Position.x;
  FY := Position.y;
  FRadius := Radius;
  FMass := Mass;
  FVecX := SpeedVektor.x;
  FVecY := SpeedVektor.y;
end;

destructor TBall.Destroy;
begin
  inherited Destroy;
end;

function TBall.GetPos: TPointF;
begin
  result.x := FX;
  result.y := FY;
end;

procedure TBall.SetPos(APos: TPointF);
begin
  FX := APos.x;
  FY := APos.y;
end;

function TBall.GetSpeed: TPointF;
begin
  result.x := FVecX;
  result.y := FVecY;
end;

procedure TBall.SetSpeed(ASpeed: TPointF);
begin
  FVecX := ASpeed.x;
  FVecY := ASpeed.y;
end;

procedure TBall.move;
begin
  FX := FX + FVecX;
  FY := FY + FVecY;
end;

procedure Tausche(var i, j: integer);
var
  k: integer;
begin
  k := i;
  i := j;
  j := k;
end;

function EllipseRechteckcollision(e1, r1: TRect): boolean;
var
  sn1, sn2, x, alpha: single;
  p1, p2: TPoint;
  n1, n2: TPointF;
  radius1, radius2: integer;
begin
  result := False;
  if e1.Left > e1.Right  then Tausche(e1.Left, e1.Right);
  if e1.Top  > e1.Bottom then Tausche(e1.Top,  e1.Bottom);
  if r1.Left > r1.Right  then Tausche(r1.Left, r1.Right);
  if r1.Top  > r1.Bottom then Tausche(r1.Top,  r1.Bottom);
  p1.x := e1.Left + (e1.Right  - e1.Left) div 2;
  p1.y := e1.Top  + (e1.Bottom - e1.Top)  div 2;
  p2.x := r1.Left + (r1.Right  - r1.Left) div 2;
  p2.y := r1.Top  + (r1.Bottom - r1.Top)  div 2;
  alpha := ArcTangens(p1.x - p2.x, p1.y - p2.y);
  x := Hypot(p1.x - p2.x, p1.y - p2.y);
  radius1 := p1.x - e1.Left;
  radius2 := p1.y - e1.Top;
  n1.x := Cosinus(alpha) * radius1 + p1.x;
  n1.y := Sinus(alpha)   * radius2 + p1.y;
  sn1 := Hypot(p1.x - n1.x, p1.y - n1.y);
  Initialize(n2);
  case Round(alpha) of
      0.. 45: begin n2.x := r1.Right;  n2.y := Round(Tangens(alpha)       * ((r1.Bottom - p2.y) / 2)) + p2.y; end;
     46.. 90: begin n2.y := r1.Top;    n2.x := Round(Tangens(alpha -  45) * ((r1.Right  - p2.x) / 2)) + p2.x; end;
     91..135: begin n2.y := r1.Top;    n2.x := Round(Tangens(alpha -  90) * ((r1.Right  - p2.x) / 2)) + p2.x; end;
    136..225: begin n2.x := r1.Left;   n2.y := Round(Tangens(alpha)       * ((r1.Bottom - p2.y) / 2)) + p2.y; end;
    226..270: begin n2.y := r1.Bottom; n2.x := Round(Tangens(alpha - 225) * ((r1.Right  - p2.x) / 2)) + p2.x; end;
    271..315: begin n2.y := r1.Bottom; n2.x := Round(Tangens(alpha - 270) * ((r1.Right  - p2.x) / 2)) + p2.x; end;
    316..360: begin n2.x := r1.Right;  n2.y := Round(Tangens(alpha)       * ((r1.Bottom - p2.y) / 2)) + p2.y; end;
  end;
  sn2 := Hypot(p2.x - n2.x, p2.y - n2.y);
  if x <= sn1 + sn2 then
    result := TRUE;
end;

procedure TBall.BorderCollision(CollisionRect: TRect; InsideCollision: boolean = TRUE);
begin
  if InsideCollision then
  begin
    // Bedeutet die Kugel befindet sich innerhalb des Rechtecks
    if ((FX - FRadius < CollisionRect.Left)   and (FVecX < 0))
    or ((FX + FRadius > CollisionRect.Right)  and (FVecX > 0)) then
      FVecX := -FVecX;
    if ((FY - FRadius < CollisionRect.Top)    and (FVecY < 0))
    or ((FY + FRadius > CollisionRect.Bottom) and (FVecY > 0)) then
      FVecY := -FVecY;
  end else
  begin
    // Bedeutet die Kugel befindet sich ausserhalb des Rechtecks
    if EllipseRechteckcollision(Rect(Round(FX - FRadius), Round(FY - FRadius),
      Round(FX + FRadius), Round(FY + FRadius)), CollisionRect) then
    begin
      if ((FY < CollisionRect.Top)    and (FVecY > 0))
      or ((FY > CollisionRect.Bottom) and (FVecY < 0)) then
        FVecY := -FVecY;
      if ((FX < CollisionRect.Left)   and (FVecX > 0))
      or ((FX > CollisionRect.Right)  and (FVecX < 0)) then
        FVecX := -FVecX;
    end;
  end;
end;

procedure TBall.Collision(const ABall: TBall);
var
  dx, dy, dxs, dys, l, // Die Variablen für den Abstand der beiden Kugeln
  m1, m2, m3, m4, // Die Variablen der Transformationsmatrix
  vp1, vp2, vs1, vs2, mtot, vp3, vp4: single;
  p: TPointF;
begin
  p := ABall.Position; // Hohlen der position der anderen Kugel
  dx := p.x - FX; // Delta x
  dy := p.y - FY; // Delta y
  dxs := dx * dx; // Da wir ein wenig Zeitoptimiert arbeiten wollen speichern wir und die Quadrate zwischen
  dys := dy * dy; // Da wir ein wenig Zeitoptimiert arbeiten wollen speichern wir und die Quadrate zwischen
  l := FRadius + ABall.Radius; // Die Strecke der beiden Radien addiert
  
  if dxs + dys <= l * l then
  begin
    l := Sqrt(dxs + dys); // Abstand
    // Berechnen der Transformationsmatrix
    m1 :=      dx / l;
    m3 := -1 * dy / l;
    m2 :=      dy / l;
    m4 :=      dx / l;
    // Koordinatentransformation teil 1
    p := ABall.SpeedVektor;
    vp1 := FVecX * m1 + FVecY * -1 * m3;
    vp2 := p.x * m1 + p.y * -1 * m3;
    if vp1 - vp2 < 0 then
      Exit; // Bälle gehen bereits auseinander, dann Exit
    // Koordinatentransformation teil 2 , aus Optimierungsgründen hinter dem Exit.
    vs1 := FVecX * -1 * m2 + FVecY * m4;
    vs2 := p.x * -1 * m2 + p.y * m4;
    // Das Verwurschteln der Massen
    mtot := FMass + ABall.Mass;
    vp3 := (FMass - ABall.Mass) / mtot * vp1 + 2 * ABall.Mass / mtot * vp2;
    vp4 := (ABall.Mass - FMass) / mtot * vp2 + 2 * FMass / mtot * vp1;
    // Rücktransformation
    FVecX := vp3 * m1 + vs1 * m3;
    FVecY := vp3 * m2 + vs1 * m4;
    p := PointF(vp4 * m1 + vs2 * m3, vp4 * m2 + vs2 * m4);
    ABall.SpeedVektor := p;
  end;
end;

procedure TBall.CalculateMass;
begin
  FMass := 4 / 3 * FRadius * FRadius * FRadius * PI;
end;

procedure TBall.Render(const APaintBox: TCairoPaintBox);
begin
  with APaintBox.Context do
  begin
    SetSourceRgb(FColor.r, FColor.g, FColor.b);
    Arc(FX, FY, FRadius, 0, 2 * PI);
    StrokePreserve;
    Fill;
  end;
end;

end.
