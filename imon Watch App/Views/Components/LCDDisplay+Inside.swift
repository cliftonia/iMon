import Foundation

// MARK: - Inside (Room)

extension LCDDisplay {

    /// The window opening (inside the frame) where the sky/weather shows.
    static let windowCols = 21...28
    static let windowRows = 2...8

    /// The square window frame on the back wall, with a cross mullion.
    static func windowFrameCells() -> [(x: Int, y: Int)] {
        let x0 = 20, x1 = 29, y0 = 1, y1 = 9
        var cells: [(x: Int, y: Int)] = []
        for x in x0...x1 { cells.append((x: x, y: y0)); cells.append((x: x, y: y1)) }
        for y in y0...y1 { cells.append((x: x0, y: y)); cells.append((x: x1, y: y)) }
        let mx = (x0 + x1) / 2, my = (y0 + y1) / 2
        for y in (y0 + 1)..<y1 { cells.append((x: mx, y: y)) }
        for x in (x0 + 1)..<x1 { cells.append((x: x, y: my)) }
        return cells
    }

    /// A floor lamp on the left — shade, pole and base — with a gleam that
    /// pulses out from the shade like sunlight.
    static func lampCells(phase: Int) -> [(x: Int, y: Int)] {
        let lx = 4
        var cells: [(x: Int, y: Int)] = []
        for x in (lx - 1)...(lx + 1) { cells.append((x: x, y: 4)) }   // shade top
        for x in (lx - 2)...(lx + 2) { cells.append((x: x, y: 5)) }   // shade mid
        for x in (lx - 1)...(lx + 1) { cells.append((x: x, y: 6)) }   // shade lip
        for y in 7...16 { cells.append((x: lx, y: y)) }               // pole
        for x in (lx - 1)...(lx + 1) { cells.append((x: x, y: 17)) }  // base
        return cells
    }

    /// Pulsing gleam rays around the lamp shade — drawn dimmer, like a glow.
    static func lampGleamCells(phase: Int) -> [(x: Int, y: Int)] {
        guard (phase / 3) % 2 == 0 else { return [] }
        let lx = 4
        return [
            (x: lx - 4, y: 5), (x: lx + 4, y: 5),
            (x: lx - 3, y: 3), (x: lx + 3, y: 3),
            (x: lx - 3, y: 7), (x: lx + 3, y: 7)
        ]
    }

    /// A potted plant in the back corner — dim background dressing.
    static func furnitureCells() -> [(x: Int, y: Int)] {
        // Leaves then pot, bottom-right.
        return [
            (x: 27, y: 14), (x: 28, y: 14), (x: 29, y: 14),
            (x: 26, y: 15), (x: 28, y: 15), (x: 30, y: 15),
            (x: 27, y: 16), (x: 28, y: 16), (x: 29, y: 16),
            (x: 27, y: 17), (x: 28, y: 17), (x: 29, y: 17)
        ]
    }
}
