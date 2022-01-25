const std = @import("std");
const fu = std.meta.field_utils;
const Allocator = std.mem.Allocator;

const CompanyInfo = struct {
    name: []const u8,
};

const TrainNetwork = struct {
    const Logistics = struct {
        const Station = struct {using allocator: *Allocator,};
        const Train = struct {using allocator: *Allocator,};
        const Scheduler = struct {using allocator: *Allocator,};
        scheduler: *Scheduler,
        stations: [5]Station,
        trains: [17]Train,
        pub fn firstStation(self: *Logistics) Station {} // hidden parameter injections required (1 *Allocator)
        pub fn lastStation(self: *Logistics) Station {} // hidden parameter injections required (1 *Allocator)
        pub fn nextStation(self: *Logistics) Station {} // hidden parameter injections required (1 *Allocator)
        pub fn prevStation(self: *Logistics) Station {} // hidden parameter injections required (1 *Allocator)
        pub fn getTrain(self: *Logistics) Train {} // hidden parameter injections required (1 *Allocator)
        const fs_lgst = @fields(@This());
        pub const all_allocator_users = fs_lgst..(
            .scheduler.* || .stations[] || .trains || fu.returns(fs, Station) || fu.returns(fs, Train) // fu.returns is shallow
        )...allocator;
    };
    const Publisher = struct {using allocator: *Allocator, using company_info: *const CompanyInfo,};
    const Region = struct {
        d: Logistics,
        e: Publisher,
    };
    const fs_tn = @fields(@This());
    const allocator_provides = fs_tn..(
        (.c || .c_byname()) .. (.d .. Logistics.all_allocator_users || .e...allocator)
        || .z...allocator
    );
    const Resources = struct {
        const FreeEnergy = struct {};
        a: Allocator,
        o: FreeEnergy,
    }
    const fr = @fields(Resources);
    const rsrc_provision = .{
        .{fr...a, allocator_provides},
        .{fr...o, fs_tn...z...o},
    };
    resources: Resources @providingDeep(rsrc_provision),
    c: Region,
    z: TimeVarianceAuthority,
    fn c_byname(self: *TrainNetwork, name: []const u8) Region {} // hidden parameter injections required (1 *Allocator, 1 *const CompanyInfo)
    fn operate(self: *TrainNetwork) void {} // hidden parameter injections required (1 *Allocator, 1 *const CompanyInfo)
};

const TransportationAuthority = struct {
    const company_info = CompanyInfo {
        .name = "Earth Transportation Authority",
    };
    t: [4]TrainNetwork @usingDeclFor(company_info, fu.recursiveIsA(@fields(TrainNetwork), Publisher)), // fu.recursiveIsA is deep
    pub fn at(self: *TransportationAuthority, i: u3) TrainNetwork { // hidden parameter injections required (1 *Allocator, 1 *const CompanyInfo)
        return self.t[i];
    }
};

const A = struct {
    a: Allocator
        @providing(@fields(A)...b...at()...allocator),
    b: TransportationAuthority,
};

const TimeVarianceAuthority = struct {using allocator: Allocator, using o: FreeEnergy, const info = "redacted";};

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
