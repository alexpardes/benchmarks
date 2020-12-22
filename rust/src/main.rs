#[derive(Clone, Copy)]
struct Point {
    x: f64,
    y: f64,
}

impl Point {
    fn new(x: f64, y: f64) -> Self {
        Self { x, y }
    }
}

impl std::ops::Sub for Point {
    type Output = Vector;

    fn sub(self, p: Point) -> Vector {
        Vector::new(self.x - p.x, self.y - p.y)
    }
}

impl std::ops::Add<Vector> for Point {
    type Output = Self;

    fn add(self, v: Vector) -> Self {
        Self::new(self.x + v.x, self.y + v.y)
    }
}

#[derive(Clone, Copy)]
struct Vector {
    x: f64,
    y: f64,
}

impl Vector {
    fn new(x: f64, y: f64) -> Self {
        Self { x, y }
    }

    fn cross(&self, v: &Vector) -> f64 {
        self.x * v.y - self.y * v.x
    }

    fn length(&self) -> f64 {
        (self.x * self.x + self.y * self.y).sqrt()
    }

    fn normalized(&self) -> Self {
        1.0 / self.length() * *self
    }
}

impl std::ops::Mul<Vector> for f64 {
    type Output = Vector;

    fn mul(self, v: Vector) -> Vector {
        Vector::new(self * v.x, self * v.y)
    }
}

impl std::ops::Div<f64> for Vector {
    type Output = Vector;

    fn div(self, c: f64) -> Self {
        Self::new(self.x / c, self.y / c)
    }
}

#[derive(Clone, Copy)]
struct Line {
    p: Point,
    v: Vector,
}

impl Line {
    fn new(p: Point, v: Vector) -> Self {
        Self { p, v }
    }

    fn _intersection(&self, line: &Line) -> Option<Point> {
        let param = self.intersection_param(line);
        if param == std::f64::INFINITY {
            return None;
        }

        Some(self.p + param * line.v)
    }

    fn intersection_param(&self, line: &Line) -> f64 {
        let cross = self.v.cross(&line.v);
        if cross == 0.0 {
            return std::f64::INFINITY;
        }

        (line.p - self.p).cross(&line.v) / cross
    }
}

#[derive(Clone, Copy)]
struct Segment {
    p1: Point,
    p2: Point,
}

impl Segment {
    fn new(p1: Point, p2: Point) -> Self {
        Self { p1, p2 }
    }

    fn intersects(&self, segment: &Segment) -> bool {
        let l1 = self.as_line();
        let l2 = segment.as_line();
        let param = l1.intersection_param(&l2);
        param >= 0.0 && param <= self.length()
    }

    fn as_line(&self) -> Line {
        Line::new(self.p1, (self.p2 - self.p1).normalized())
    }

    fn length(&self) -> f64 {
        (self.p2 - self.p1).length()
    }
}

struct Polygon {
    points: Vec<Point>,
}

impl Polygon {
    fn _new() -> Self {
        Polygon { points: Vec::new() }
    }

    fn new_rect(left: f64, top: f64, width: f64, height: f64) -> Self {
        let bottom = top + height;
        let right = left + width;

        let points = vec![
            Point::new(left, top),
            Point::new(left, bottom),
            Point::new(right, bottom),
            Point::new(right, top),
        ];
        Polygon { points }
    }

    fn intersects(&self, poly: &Polygon) -> bool {
        for i in 0..self.points.len() {
            let s1 = self.segment(i);
            for j in 0..poly.points.len() {
                let s2 = poly.segment(j);
                if s1.intersects(&s2) {
                    return true;
                }
            }
        }
        return false;
    }

    fn segment(&self, i: usize) -> Segment {
        Segment::new(self.points[i], self.points[(i + 1) % self.points.len()])
    }
}

fn make_rect(x: i32) -> Polygon {
    let f = x as f64;
    Polygon::new_rect(f, f, 100.0, 100.0)
}

fn main() {
    let polys: Vec<_> = (0..1000).map(make_rect).collect();
    let start = std::time::Instant::now();
    let mut n_intersections = 0;
    for i in 0..polys.len() {
        for j in i + 1..polys.len() {
            if polys[i].intersects(&polys[j]) {
                n_intersections += 1;
            }
        }
    }
    let intersection_time = start.elapsed();
    println!("Intersections: {}", n_intersections);
    println!("Intersection time: {:?}", intersection_time);
}
