import Foundation

// MARK: - Step Crediting

extension PetPresenter {

    /// How many missed days a single catch-up will settle with HealthKit.
    static let maxCatchUpDays = 7

    /// Folds today's live step count into the lifetime evolution accumulator,
    /// applying the lazy-day decay on a calendar rollover.
    ///
    /// A day that ends while the app is closed is settled asynchronously first:
    /// HealthKit keeps counting when nothing is watching, so rolling over on
    /// the last figure the app happened to see would both lose that evening's
    /// steps and risk charging a lazy-day penalty to a day that was not lazy.
    func creditSteps() {
        guard let steps = currentSteps() else { return }
        let progress = StepProgress.Progress(of: state)

        guard let trackedDay = progress.trackedDay,
              !trackedDay.isSameDay(as: .now)
        else {
            rollOver(progress, todaySteps: steps)
            return
        }

        guard dayRecoveryTask == nil else { return }
        dayRecoveryTask = Task { [weak self] in
            await self?.settleAndRollOver(trackedDay: trackedDay, fallbackSteps: steps)
        }
    }

    /// Credits the closed day's true total, then rolls the accumulator over.
    /// Runs even when the tail is unavailable, so a failed lookup delays the
    /// rollover by one fetch rather than stalling it forever.
    /// Every whole day missed is fetched before any state is touched, so the
    /// accumulator is advanced in one synchronous stretch. Splitting it this
    /// way keeps an evolution accepted mid-fetch from being overwritten.
    func settleAndRollOver(trackedDay: Date, fallbackSteps: Int) async {
        let totals = await missedDayTotals(from: trackedDay)
        defer { dayRecoveryTask = nil }
        guard !Task.isCancelled else { return }

        var progress = StepProgress.Progress(of: state)
        guard progress.trackedDay?.isSameDay(as: trackedDay) == true else { return }

        // Each entry settles its own day: the first credits the tracked day's
        // uncounted tail, and every later one rolls the previous day over with
        // that day's true total deciding the lazy-day verdict.
        for entry in totals {
            progress = StepProgress.advance(
                progress,
                todaySteps: entry.total,
                now: entry.day,
                stagePenalty: state.species.stage.lazyDayPenalty
            )
        }
        rollOver(progress, todaySteps: currentSteps() ?? fallbackSteps)
        save()
    }

    /// Settled totals for the tracked day and each whole day missed since,
    /// oldest first. Bounded by days walked — not by fetches that succeeded —
    /// so a long absence or a failing HealthKit cannot fan out into dozens of
    /// queries; days beyond the bound go uncredited and unpenalised. A tracked
    /// day in the future (a clock set back) walks nowhere and returns empty.
    func missedDayTotals(from trackedDay: Date) async -> [(day: Date, total: Int)] {
        let calendar = Calendar.current
        var totals: [(day: Date, total: Int)] = []
        var cursor = trackedDay

        for _ in 0..<Self.maxCatchUpDays where cursor < .now && !calendar.isDateInToday(cursor) {
            if let total = await finalSteps(cursor) {
                totals.append((cursor, total))
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return totals
    }

    func rollOver(_ progress: StepProgress.Progress, todaySteps: Int) {
        StepProgress.advance(
            progress,
            todaySteps: todaySteps,
            now: .now,
            stagePenalty: state.species.stage.lazyDayPenalty
        )
        .write(to: &state)
    }
}
