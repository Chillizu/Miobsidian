## Hash collision in weak MD4 and SHA-1

### MD4 collision

Unlike group-based cryptosystems whose security rests on the hidden order of a finite abelian group, as MD4 operates on $\{0,1\}^{32}$ using bitwise AND, OR, XOR, integer addition modulo $2^{32}$, and cyclic shifts, the security of MD4 relies entirely on the intricate interplay of bitwise operations and modular carries—a chaotic ecosystem that ultimately proved fragile against precise differential manipulation.

While addition modulo $2^{32}$ does form a finite abelian group, MD4 forcibly mixes it with non-group Boolean logic (AND/OR/XOR). In a sound design, the Boolean layer would ensure that any input difference avalanches unpredictably. In MD4, however, the propagation rule of addition is fully deterministic:
$$\Delta(x+y)=\Delta x+\Delta y \pmod{2^{32}}.$$
so the carry chain simply executes this linear rule bit by bit, giving difference propagation a traceable structure. The Boolean layer cannot eliminate this structure; it can only impose local constraints on it. Once those constraints are satisfied, the avalanche is tamed, and the compression function degenerates to a linear system over the abelian group.