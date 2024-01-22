
/-%%
The approach here is completely standard. We follow the use of $\mathcal{M}(\widetilde{1_{\epsilon}})$ as in Kontorovich 2015.

%%-/


/-%%
It has already been established that zeta doesn't vanish on the 1 line, and has a pole at $s=1$ of order 1.
We also have that
$$
-\frac{\zeta'(s)}{\zeta(s)} = \sum_{n=1}^\infty \frac{\Lambda(n)}{n^s}.
$$

The main object of study is the following inverse Mellin-type transform, which will turn out to be a smoothed Chebyshev function.
\begin{definition}\label{SmoothedChebyshev}
Fix $\epsilon>0$, and a bumpfunction $\psi$ supported in $[1/2,2]$. Then we define the smoothed Chebyshev function $\psi_{\epsilon}$ from $\mathbb{R}_{>0}$ to $\mathbb{C}$ by
$$\psi_{\epsilon}(X) = \frac{1}{2\pi i}\int_{(2)}\frac{-\zeta'(s)}{\zeta(s)}
\mathcal{M}(\widetilde{1_{\epsilon}})(s)
X^{s}ds.$$
\end{definition}
%%-/

/-%%
Inserting the Dirichlet series expansion of the log derivative of zeta, we get the following.
\begin{theorem}\label{SmoothedChebyshevDirichlet}
We have that
$$\psi_{\epsilon}(X) = \sum_{n=1}^\infty \Lambda(n)\widetilde{1_{\epsilon}}(n/X).$$
\end{theorem}
%%-/

/-%%
\begin{proof}
We have that
$$\psi_{\epsilon}(X) = \frac{1}{2\pi i}\int_{(2)}\sum_{n=1}^\infty \frac{\Lambda(n)}{n^s}
\mathcal{M}(\widetilde{1_{\epsilon}})(s)
X^{s}ds.$$
We have enough decay (thanks to quadratic decay of $\mathcal{M}(\widetilde{1_{\epsilon}})$) to justify the interchange of summation and integration. We then get
$$\psi_{\epsilon}(X) =
\sum_{n=1}^\infty \Lambda(n)\frac{1}{2\pi i}\int_{(2)}
\mathcal{M}(\widetilde{1_{\epsilon}})(s)
(n/X)^{-s}
ds
$$
and apply the Mellin inversion formula (Theorem \ref{MellinInversion}).
\end{proof}
%%-/

/-%%
The smoothed Chebyshev function is close to the actual Chebyshev function.
\begin{theorem}\label{SmoothedChebyshevClose}
We have that
$$\psi_{\epsilon}(X) = \psi(X) + O(\epsilon X \log X).$$
\end{theorem}
%%-/

/-%%
\begin{proof}
Take the difference. By Lemma \ref{Smooth1Properties}, the sums agree except when $1-c \epsilon \leq n/X \leq 1+c \epsilon$. This is an interval of length $\ll \epsilon X$, and the summands are bounded by $\Lambda(n) \ll \log X$.
\end{proof}
%%-/

/-%%
Returning to the definition of $\psi_{\epsilon}$, fix a large $T$ to be chosen later, and pull contours (via rectangles!) to go
from $2$ up to $2+iT$, then over to $1+iT$, and up from there to $1+i\infty$ (and symmetrically in the lower half plane). Call
this path $\gamma$. The
rectangles involved are all where the integrand is holomorphic, so there is no change.
\begin{theorem}\label{SmoothedChebyshevPull1}
We have that
$$\psi_{\epsilon}(X) = \frac{1}{2\pi i}\int_{\gamma}\frac{-\zeta'(s)}{\zeta(s)}
\mathcal{M}(\widetilde{1_{\epsilon}})(s)
X^{s}ds.$$
\end{theorem}
%%-/

/-%%
Then, since $\zeta$ doesn't vanish on the 1-line, there is a $\delta$ (depending on $T$), so that the box $[1-\delta,1] \times_{ℂ} [-T,T]$ is free of zeros of $\zeta$.
The rectangle with opposite corners $1-\delta - i T$ and $2+iT$ contains a single pole of $-\zeta'/\zeta$ at $s=1$, and the residue is $1$ (from Theorem \ref{ResidueOfLogDerivative}).
\begin{theorem}\label{ZeroFreeBox}
$-\zeta'/\zeta$ is holomorphic on the box $[1-\delta,2] \times_{ℂ} [-T,T]$, except a simple pole with residue $1$ at $s$=1.
\end{theorem}
%%-/

/-%%
Inserting this into $\psi_{\epsilon}$, we get
%%-/
