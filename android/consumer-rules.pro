# kotlinx.parcelize.Parcelize is a compile-time annotation used by the PayMob SDK.
# The annotation class itself is not present at runtime, so R8 must be told to ignore it.
-dontwarn kotlinx.parcelize.Parcelize
-dontwarn kotlinx.parcelize.**
