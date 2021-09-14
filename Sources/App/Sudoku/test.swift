class A {
    var s : String
    init(s:String) {
        self.s = s
    }
}

class B {
    let s : A
    init(s:A) {
        self.s = s
    }
}

func test() {
    let a = A(s:"hi")
    let b = B(s:a)

    print(a.s)
    b.s.s = "bye"
    print(b.s.s)
    print(a.s)
}
