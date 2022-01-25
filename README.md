# injected_fields
Injected fields is a possible feature for Zig or any programming language; usage is given in `injection.zig`. Associated with the feature are two auxiliary features called `tenum` as described in `tenums.txt`, and `Access` as described in `Access.txt`. These two features are not necessary for injected fields, e.g. if strings are used to specify field access (see `stringly.zig`, a previous idea).

## Motivation
- separation of context provision logic from application logic
- easier modification of structure context requirements or options without requiring modification of all callsites
- decreased clutter from non-"volatile"/context-type parameters; decreased chance of accidentally changing an argument that is required to be the same through different function calls (such as a `std.mem.Allocator` in `std.array_list.ArrayListUnmanaged`)
- managed container with the same code and flexibility as unmanaged container
- easier delegation of tasks to sub-structure methods without need for excessive parameters or redundant physical pointer fields 

## Synopsis

```zig
const TrainNetwork = struct {
    const Resources = struct {
        using a: Allocator,
    };
    resources: Resources,
};

const TransportationAuthority = struct {
    pub fn at(self: *TransportationAuthority, i: u3) TrainNetwork { // hidden parameter injections required (1 *Allocator)
        return self.t[i];
    }
};

const A = struct {
    a: Allocator
        @providing(@fields(A)...b...at()...resources...a),
    b: TransportationAuthority,
};
```

## Description
Injected fields (aka `using` fields) seem similar to "dynamic scoping" [[1]](https://wiki.c2.com/?DynamicScoping); "implicit parameters" similar to as in Scala 2 [[2]](https://www.reddit.com/r/ProgrammingLanguages/comments/dvq7ld/implicitly_passed_parameters/), Zig [issue #1286](https://github.com/ziglang/zig/issues/1286); "givens" [[3]](https://docs.scala-lang.org/scala3/reference/contextual/givens.html) in Scala 3; "dependency injection"; or "Explicit Management of Implicit Context (EMIC)" [[4]](https://wiki.c2.com/?ExplicitManagementOfImplicitContext). They are explicitly configured in an OOP pattern.

A struct may have a `using` field, which is "virtual" in the sense that it does not actually exist in memory representation of the struct. Rather, this field is required to be provided by configuration in a program that contains instances of the struct. Any parent structure using it can be configured to provide the field.

There must be exactly 1 candidate injection argument for every `using` field or else it is a compile error.

The compiler automatically injects the provided value as arguments/parameters through the necessary function calls. If you somehow get a pointer to an instance of a struct with the `using` field, then the compiler can automatically obtain the correct value for that field.

The `using` fields are always pointers, because they do not have physical storage but refer to an object stored elsewhere. Technically, they could be available on the stack because they are implemented as parameters, but this would be misleading because mutation would not be persistent. So there is an implicit address-of operation for the builtin functions.

If you want to provide a more complex way of obtaining the correct resource, e.g.
- you can call a function on (or method of) the injected field at the use-site.
- you can create an intermediate struct that is stored e.g. on the stack, which obtains with a function call the resource into a field that is `@providing()` for the use-site.

Strictly speaking there seems to be an aspect of parameter injection and an aspect of to-above field aliasing here. Zig [issue #7311](https://github.com/ziglang/zig/issues/7311) seems to be proposing to-below field aliasing limited to one level down.

Unused injected fields are allowed, just as not using a physical field is allowed. Not a strong requirement.

### Benefits
- simplicity
- increases focus on "volatile" parameters (not in the RAM sense)
- maps a field or declaration to a field; so does not cause hidden control flow, only augments explicit control flow in a hidden manner
- equalizes the ease of unmanaged structures to that of managed structures, which was made easy with similarly "hidden" resource/context usage by the OOP pattern
- in one sense the semantics of injected context parameters is more accurate than that of passing contexts through several function calls, because those function calls are often inlined by the compiler
- easier to optimize allocator organization, adapt it incrementally. easy to provide allocators of different types to satisfy different requirements (random access (hugepages useful), sequential access (smaller pages ok), short usage period (arena-type), etc.), merge arena-type allocations with similar usage period. or to ignore that detail until it is useful to optimize it, but not later have extra hassle when it is.

For the last point, a simple example is if you create a `struct` that either uses its own allocator field or uses the `std.heap.page_allocator`. If you ever want to change it to use a provided allocator that is not stored within the struct, you will have to modify every method that uses the allocator, and every callsite.

### Drawbacks and counterarguments

- complexity
- too many hidden parameters passed too deeply in non-inlined function calls

I think the compiler can optimize it by passing the hidden parameter through a static memory location, or single-purpose stack if there are deep non-inlined function call origin possibilities (like using "globals" but in a compiler-enforced correct fashion).

- not a significant optimization vs. physical fields for `struct`s on the stack, given compiler optimizer
- perhaps language feature is not necessary (simulation with metaprogramming)
- less obvious which function calls use a resource at callsites for e.g. currently unmanaged containers that switch to `using` fields

However, the last point is not a fundamental difference from the possibilities in the current language, because any struct that you utilize in your program currently, however deeply in a struct hierarchy, could have e.g. an `Allocator` field or declaration that uses a default allocator without even taking one for a constructor. You would not currently see it using resource parameters in the function call chain. This feature could actually reduce hidden resource usage by increasing the appeal of unmanaged (but managed-like) structures, where at least the resource usage is declared higher in the struct hierarchy.
