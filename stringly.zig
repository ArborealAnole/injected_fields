const Allocator = struct {};

const CompanyInfo = struct {
    name: []const u8,
};

const TrainNetwork = struct {
    const Logistics = struct {
        const Station = struct {using allocator: *Allocator,};
        const Train = struct {using allocator: *Allocator,};
        const Scheduler = struct {using allocator: *Allocator,};
        scheduler: Scheduler,
        stations: [5]Station,
        trains: [17]Train,
        pub fn firstStation(self: *Logistics) Station {} // hidden parameter injections required (1 *Allocator)
        pub fn lastStation(self: *Logistics) Station {} // hidden parameter injections required (1 *Allocator)
        pub fn nextStation(self: *Logistics) Station {} // hidden parameter injections required (1 *Allocator)
        pub fn prevStation(self: *Logistics) Station {} // hidden parameter injections required (1 *Allocator)
        pub fn getTrain(self: *Logistics) Train {} // hidden parameter injections required (1 *Allocator)
    };
    const Publisher = struct {using allocator: *Allocator, using company_info: *const CompanyInfo,};
    const Region = struct {
        d: Logistics,
        e: Publisher,
    };
    using allocator: *Allocator
        @providing(.{
            .{"c[]|c_byname().", .{
                "d.scheduler|stations|trains|()Station|()Train.allocator",
                "e.allocator",
            }},
            .{"z.allocator"},
        }),
    c: Region,
    z: TimeVarianceAuthority,
    fn c_byname(self: *TrainNetwork, name: []const u8) Region {} // hidden parameter injections required (1 *Allocator, 1 *const CompanyInfo)
    fn operate(self: *TrainNetwork) void {} // hidden parameter injections required (1 *Allocator, 1 *const CompanyInfo)
};

const TransportationAuthority = struct {
    const company_info = CompanyInfo {
        .name = "Earth Transportation Authority",
    };
    t: [4]TrainNetwork @usingDeclFor(company_info, .{".**"}),
    pub fn at(self: *TransportationAuthority, i: u3) TrainNetwork { // hidden parameter injections required (1 *Allocator, 1 *const CompanyInfo)
        return self.t[i];
    }
};

const A = struct {
    a: Allocator
        @providing(.{"b.at().allocator"}),
    b: TransportationAuthority,
};

const TimeVarianceAuthority = struct {using allocator: Allocator, const info = "redacted";};

fn runTrains(tn: *TrainNetwork) void { // hidden parameter injections required (1 *Allocator, 1 *const CompanyInfo)
   tn.operate();
}

fn operateTA(ta: *TransportationAuthority) void { // hidden parameter injections required (1 *Allocator)
    ta.at(2).runTrains();
}

test "" {
    var a = A{};
    a.b.operateTA();
}
