require "../core/vector/*"
require "./*"

class Vector(T, D)
  # Computes the maximum value of a vector
  #
  # ```
  # v = Vector.new [1, 2, 3, 4]
  # v.max # => 4
  # ```
  def max
    Bottle::Core::VectorStats.vector_max(@ptr)
  end

  # Computes the minimum value of a vector
  #
  # ```
  # v = Vector.new [1, 2, 3, 4]
  # v.min # => 1
  # ```
  def min
    Bottle::Core::VectorStats.vector_min(@ptr)
  end

  # Computes the min and max values of a vector
  #
  # ```
  # v = Vector.new [1, 2, 3, 4]
  # v.ptpv # => {1, 4}
  # ```
  def ptpv
    Bottle::Core::VectorStats.vector_ptpv(@ptr)
  end

  # Computes the "peak to peak" of a vector (max - min)
  #
  # ```
  # v = Vector.new [1, 2, 3, 4]
  # v.ptp # => 3
  # ```
  def ptp
    Bottle::Core::VectorStats.vector_ptp(@ptr)
  end

  # Computes the index of the maximum value of a vector
  #
  # ```
  # v = Vector.new [1, 2, 3, 4]
  # v.idxmax # => 3
  # ```
  def idxmax
    Bottle::Core::VectorStats.vector_idxmax(@ptr)
  end

  # Computes the index of the minimum value of a vector
  #
  # ```
  # v = Vector.new [1, 2, 3, 4]
  # v.idxmin # => 0
  # ```
  def idxmin
    Bottle::Core::VectorStats.vector_idxmin(@ptr)
  end

  # Computes the indexes of the minimum and maximum values of a vector
  #
  # ```
  # v = Vector.new [1, 2, 3, 4]
  # v.ptpidx # => {0, 3}
  # ```
  def ptpidx
    Bottle::Core::VectorStats.vector_ptpidx(@ptr)
  end

  # Computes the cumulative sum of a vector
  #
  # ```
  # v = Vector.new [1, 2, 3, 4]
  # v.cumsum # => [1, 3, 6, 10]
  # ```
  def cumsum
    Bottle::Core::VectorStats.vector_cumsum(self.copy)
  end

  # Computes the cumulative product of a vector
  #
  # ```
  # v = Vector.new [1, 2, 3, 4]
  # v.cumprod # => [1, 2, 6, 24]
  # ```
  def cumprod
    Bottle::Core::VectorStats.vector_cumprod(self.copy)
  end
end