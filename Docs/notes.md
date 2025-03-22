# Notes, Limitations, and Gotchas

## Instance Variable Access Restrictions (Private / Protected)

All instance variables are publicly accessible. Extending the private / protected access controls to cover instance variables may be added in the future. A general convention of adding an leading underscore to things which shouldn't be used externally (i.e. private members / methods) is encouraged. If true private members are needed, another alternative is to create scope-limited lookup tables or functions within the file where the class is defined.

## Classes are Immutable and Should be Atomically Defined

One gotcha of LibTSMClass is that all methods and static fields of a class must be fully defined before that class is subclassed or instantiated. This means that changing the definition of a class at runtime is not supported, and may lead to undefined behavior. Along the same lines, once a class's methods are defined, they may not be changed later on.

## Highly-Performant Base Classes

Inheritance is one of the most powerful uses of OOP, and LibTSMClass fully supports it. However, for cases where performance is of the utmost importance, LibTSMClass is heavily optimized to reduce the overhead of a class which does not subclass anything to be as close to direct table access as possible (without metamethod calls).
