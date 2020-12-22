import math
import times
import sugar

type
    Point* = object
        x*, y*: float64

type
    Vector* = object
        x*, y*: float64

proc newPoint(x: float64, y: float64): Point =
    Point(x: x, y: y)

proc newVector(x: float64, y: float64): Vector =
    Vector(x: x, y: y)

proc `-`(a: Point, b: Point): Vector =
    newVector(a.x - b.x, a.y - b.y)

proc `+`(p: Point, v: Vector): Point =
    newPoint(p.x + v.x, p.y + v.y)

proc `*`(c: float64, v: Vector): Vector =
    newVector(c * v.x, c * v.y)

proc `/`(v: Vector, c: float64): Vector =
    newVector(v.x / c, v.y / c)

proc cross*(a: Vector, b: Vector): SomeFloat =
    a.x * b.y - a.y * b.x

proc length*(v: Vector): float64 =
    sqrt(v.x * v.x + v.y * v.y)

proc normalized*(v: Vector): Vector =
    v / v.length()

type
    Line* = object
        p: Point
        v: Vector

proc intersection_param*(line1: Line, line2: Line): SomeFloat =
    let cross = line1.v.cross(line2.v)
    if cross == 0:
        return Inf

    result = (line2.p - line1.p).cross(line2.v) / cross


type
    Segment* = object
        p1: Point
        p2: Point

proc length*(s: Segment): SomeFloat =
    (s.p2 - s.p1).length()

proc as_line*(s: Segment): Line =
    Line(p: s.p1, v: (s.p2 - s.p1).normalized())

proc intersects*(s1: Segment, s2: Segment): bool =
    let t = s1.as_line().intersection_param(s2.as_line())
    0 <= t and t <= s1.length()

type
    Poly* = object
        points: seq[Point]

proc new_rect*(left: float64, top: float64, width: float64, height: float64): Poly =
    let bottom = top + height
    let right = left + width

    let points = @[
        newPoint(left, top),
        newPoint(left, bottom),
        newPoint(right, bottom),
        newPoint(right, top),
    ]
    Poly(points: points)

proc segment(p: Poly, i: SomeOrdinal): Segment =
    Segment(p1: p.points[i], p2: p.points[(i + 1) mod p.points.len()])

proc intersects*(p1: Poly, p2: Poly): bool =
    for i in 0..(p1.points.len() - 1):
        let s1 = p1.segment(i)
        for j in 0..(p2.points.len() - 1):
            let s2 = p2.segment(j)
            if s1.intersects(s2):
                return true

    return false

proc make_rect(x: int): Poly =
    let f = float64(x)
    new_rect(f, f, 100, 100)

proc main*(): void =
    let polys = collect(newSeq):
        for i in 0..999:
            make_rect(i)

    let start = cpuTime()
    var n = 0
    for i in 0 .. polys.len() - 1:
        for j in i + 1 .. polys.len() - 1:
            if polys[i].intersects(polys[j]):
                n += 1

    let duration = cpuTime() - start
    echo duration
    echo n

main()