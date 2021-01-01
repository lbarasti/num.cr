# Copyright (c) 2020 Crystal Data Contributors
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Num
  extend self

  # Broadcasts a `Tensor` to a new shape.  Returns a read-only
  # view of the original `Tensor`.  Many elements in the `Tensor`
  # will refer to the same memory location, and the result is
  # rarely contiguous.
  #
  # Shapes must be broadcastable, and an error will be raised
  # if broadcasting fails.
  #
  # Arguments
  # ---------
  # *shape* : Array(Int)
  #   The shape of the desired output `Tensor`
  #
  # Examples
  # --------
  # ```
  # a = Tensor.from_array [1, 2, 3]
  # a.broadcast_to([3, 3])
  #
  # # [[1, 2, 3],
  # #  [1, 2, 3],
  # #  [1, 2, 3]]
  # ```
  def broadcast_to(arr : Tensor(U, CPU(U)), shape : Array(Int)) forall U
    strides = Num::Internal.strides_for_broadcast(arr.shape, arr.strides, shape)
    Tensor.new(arr.data, shape, strides, arr.offset, U)
  end

  # Transform's a `Tensor`'s shape.  If a view can be created,
  # the reshape will not copy data.  The number of elements
  # in the `Tensor` must remain the same.
  #
  # Arguments
  # ---------
  # *result_shape* : Array(Int)
  #   Result shape for the `Tensor`
  #
  # Examples
  # --------
  # ```
  # a = Tensor.from_array [1, 2, 3, 4]
  # a.reshape([2, 2])
  #
  # # [[1, 2],
  # #  [3, 4]]
  # ```
  def reshape(arr : Tensor(U, CPU(U)), shape : Array(Int)) forall U
    strides = Num::Internal.shape_and_strides_for_reshape(arr.shape, shape)
    arr = arr.dup(Num::RowMajor) unless arr.is_c_contiguous
    Tensor(U, CPU(U)).new(arr.data, shape, strides, arr.offset, U)
  end

  # Transform's a `Tensor`'s shape.  If a view can be created,
  # the reshape will not copy data.  The number of elements
  # in the `Tensor` must remain the same.
  #
  # Arguments
  # ---------
  # *result_shape* : Array(Int)
  #   Result shape for the `Tensor`
  #
  # Examples
  # --------
  # ```
  # a = Tensor.from_array [1, 2, 3, 4]
  # a.reshape([2, 2])
  #
  # # [[1, 2],
  # #  [3, 4]]
  # ```
  def reshape(arr : Tensor(U, CPU(U)), *shape : Int) forall U
    reshape(arr, shape.to_a)
  end

  # Flattens a `Tensor` to a single dimension.  If a view can be created,
  # the reshape operation will not copy data.
  #
  # Arguments
  # ---------
  #
  # Examples
  # --------
  # ```
  # a = Tensor.new([2, 2]) { |i| i }
  # a.flat # => [0, 1, 2, 3]
  # ```
  def flat(arr : Tensor(U, CPU(U))) forall U
    reshape(arr, -1)
  end

  # Move axes of a Tensor to new positions, other axes remain
  # in their original order
  #
  # Arguments
  # ---------
  # *arr* : Tensor
  #   Tensor to permute
  # *source* : Array(Int)
  #   Original positions of axes to move
  # *destination*
  #   Destination positions to permute axes
  #
  # Examples
  # --------
  # ```
  # a = Tensor(Int8, CPU(Int8)).new([3, 4, 5])
  # moveaxis(a, [0], [-1]).shape # => 4, 5, 3
  # ```
  def moveaxis(arr : Tensor(U, CPU(U)), source : Array(Int), destination : Array(Int)) forall U
  end

  # Move axes of a Tensor to new positions, other axes remain
  # in their original order
  #
  # Arguments
  # ---------
  # *arr* : Tensor
  #   Tensor to permute
  # *source* : Array(Int)
  #   Original positions of axes to move
  # *destination*
  #   Destination positions to permute axes
  #
  # Examples
  # --------
  # ```
  # a = Tensor(Int8, CPU(Int8)).new([3, 4, 5])
  # moveaxis(a, [0], [-1]).shape # => 4, 5, 3
  # ```
  def moveaxis(arr : Tensor(U, CPU(U)), source : Int, destination : Int) forall U
    axes = Num::Internal.move_axes_for_transpose(arr.rank, source, destination)
    transpose(arr, axes)
  end

  # Permutes two axes of a `Tensor`.  This will always create a view
  # of the permuted `Tensor`
  #
  # Arguments
  # ---------
  # *a* : Int
  #   First axis of permutation
  # *b* : Int
  #   Second axis of permutation
  #
  # Examples
  # --------
  # ```
  # a = Tensor.new([4, 3, 2]) { |i| i }
  # a.swap_axes(2, 0)
  #
  # # [[[ 0,  6, 12, 18]
  # #   [ 2,  8, 14, 20]
  # #   [ 4, 10, 16, 22]]
  # #
  # #  [[ 1,  7, 13, 19]
  # #   [ 3,  9, 15, 21]
  # #   [ 5, 11, 17, 23]]]
  # ```
  def swap_axes(arr : Tensor(U, CPU(U)), a : Int, b : Int) forall U
    axes = Num::Internal.swap_axes_for_transpose(arr.rank, a, b)
    transpose(arr, axes)
  end

  # Permutes a `Tensor`'s axes to a different order.  This will
  # always create a view of the permuted `Tensor`.
  #
  # Arguments
  # ---------
  # *axes* : Array(Int)
  #   New ordering of axes for the permuted `Tensor`.  If empty,
  #   a full transpose will occur
  #
  # Examples
  # --------
  # ```
  # a = Tensor.new([4, 3, 2]) { |i| i }
  # a.transpose([2, 0, 1])
  #
  # # [[[ 0,  2,  4],
  # #   [ 6,  8, 10],
  # #   [12, 14, 16],
  # #   [18, 20, 22]],
  # #
  # #  [[ 1,  3,  5],
  # #   [ 7,  9, 11],
  # #   [13, 15, 17],
  # #   [19, 21, 23]]]
  # ```
  def transpose(arr : Tensor(U, CPU(U)), axes : Array(Int) = [] of Int32) forall U
    shape, strides = Num::Internal.shape_and_strides_for_transpose(arr.shape, arr.strides, axes)
    Tensor(U, CPU(U)).new(arr.data, shape, strides, arr.offset, U)
  end

  # Permutes a `Tensor`'s axes to a different order.  This will
  # always create a view of the permuted `Tensor`.
  #
  # Arguments
  # ---------
  # *axes* : Array(Int)
  #   New ordering of axes for the permuted `Tensor`.  If empty,
  #   a full transpose will occur
  #
  # Examples
  # --------
  # ```
  # a = Tensor.new([4, 3, 2]) { |i| i }
  # a.transpose([2, 0, 1])
  #
  # # [[[ 0,  2,  4],
  # #   [ 6,  8, 10],
  # #   [12, 14, 16],
  # #   [18, 20, 22]],
  # #
  # #  [[ 1,  3,  5],
  # #   [ 7,  9, 11],
  # #   [13, 15, 17],
  # #   [19, 21, 23]]]
  # ```
  def transpose(arr : Tensor(U, CPU(U)), *args : Int) forall U
    transpose(arr, args.to_a)
  end

  # Join a sequence of `Tensor`s along an existing axis.  The `Tensor`s
  # must have the same shape for all axes other than the axis of
  # concatenation
  #
  # Arguments
  # ---------
  # *t_array* : Array(Tensor | Enumerable)
  #   Array of items to concatenate.  All elements
  #   will be cast to `Tensor`, so arrays can be passed here, but
  #   all inputs must have the same generic type.  Union types
  #   are not allowed
  # *axis* : Int
  #   Axis of concatenation, negative axes are allowed
  #
  # Examples
  # --------
  # ```
  # a = [1, 2, 3]
  # b = Tensor.from_array [4, 5, 6]
  # Num.concat([a, b], 0) # => [1, 2, 3, 4, 5, 6]
  #
  # c = Tensor.new([3, 2, 2]) { |i| i / 2 }
  # Num.concat([c, c, c], -1)
  #
  # # [[[0  , 0.5, 0  , 0.5, 0  , 0.5],
  # #  [1  , 1.5, 1  , 1.5, 1  , 1.5]],
  # #
  # # [[2  , 2.5, 2  , 2.5, 2  , 2.5],
  # #  [3  , 3.5, 3  , 3.5, 3  , 3.5]],
  # #
  # # [[4  , 4.5, 4  , 4.5, 4  , 4.5],
  # #  [5  , 5.5, 5  , 5.5, 5  , 5.5]]]
  # ```
  def concatenate(arrs : Array(Tensor(U, CPU(U))), axis : Int) forall U
    Num::Internal.assert_min_dimension(tensor_array, 1)
    new_shape = tensor_array[0].shape.dup

    axis = Num::Internal.clip_axis(axis, new_shape.size)
    new_shape[axis] = 0

    shape = Num::Internal.concat_shape(tensor_array, axis, new_shape)
    t = tensor_array[0].class.new(shape)

    lo = [0] * t.rank
    hi = shape.dup
    hi[axis] = 0

    tensor_array.each do |a|
      if a.shape[axis] != 0
        hi[axis] += a.shape[axis]
        ranges = lo.zip(hi).map do |i, j|
          i...j
        end
        t[ranges] = a
        lo[axis] = hi[axis]
      end
    end
    t
  end

  # Join a sequence of `Tensor`s along an existing axis.  The `Tensor`s
  # must have the same shape for all axes other than the axis of
  # concatenation
  #
  # Arguments
  # ---------
  # *t_array* : Array(Tensor | Enumerable)
  #   Array of items to concatenate.  All elements
  #   will be cast to `Tensor`, so arrays can be passed here, but
  #   all inputs must have the same generic type.  Union types
  #   are not allowed
  # *axis* : Int
  #   Axis of concatenation, negative axes are allowed
  #
  # Examples
  # --------
  # ```
  # a = [1, 2, 3]
  # b = Tensor.from_array [4, 5, 6]
  # Num.concat([a, b], 0) # => [1, 2, 3, 4, 5, 6]
  #
  # c = Tensor.new([3, 2, 2]) { |i| i / 2 }
  # Num.concat([c, c, c], -1)
  #
  # # [[[0  , 0.5, 0  , 0.5, 0  , 0.5],
  # #  [1  , 1.5, 1  , 1.5, 1  , 1.5]],
  # #
  # # [[2  , 2.5, 2  , 2.5, 2  , 2.5],
  # #  [3  , 3.5, 3  , 3.5, 3  , 3.5]],
  # #
  # # [[4  , 4.5, 4  , 4.5, 4  , 4.5],
  # #  [5  , 5.5, 5  , 5.5, 5  , 5.5]]]
  # ```
  def concatenate(*arrs : Tensor(U, CPU(U)), axis : Int) forall U
    concatenate(arrs.to_a, axis)
  end

  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  def stack(arrs : Array(Tensor(U), CPU(U)), axis : Int) forall U
  end

  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  #
  def stack(*arrs : Tensor(U, CPU(U)), axis : Int) forall U
  end

  # Stack an array of `Tensor`s in sequence row-wise.  While this
  # method can take `Tensor`s with any number of dimensions, it makes
  # the most sense with rank <= 3
  #
  # Arguments
  # *t_array* : Array(Tensor | Enumerable)
  #   `Tensor`s to concatenate
  #
  # Examples
  # --------
  # ```
  # a = [1, 2, 3].to_tensor
  # Num.vstack([a, a])
  #
  # # [[1, 2, 3],
  # #  [1, 2, 3]]
  # ```
  def vstack(arrs : Array(Tensor(U, CPU(U)))) forall U
    concatenate(arrs, 0)
  end

  # Stack an array of `Tensor`s in sequence row-wise.  While this
  # method can take `Tensor`s with any number of dimensions, it makes
  # the most sense with rank <= 3
  #
  # Arguments
  # *t_array* : Array(Tensor | Enumerable)
  #   `Tensor`s to concatenate
  #
  # Examples
  # --------
  # ```
  # a = [1, 2, 3].to_tensor
  # Num.vstack([a, a])
  #
  # # [[1, 2, 3],
  # #  [1, 2, 3]]
  # ```
  def vstack(*arrs : Tensor(U, CPU(U))) forall U
    concatenate(arrs.to_a, 0)
  end

  # Stack an array of `Tensor`s in sequence column-wise.  While this
  # method can take `Tensor`s with any number of dimensions, it makes
  # the most sense with rank <= 3
  #
  # For one dimensional `Tensor`s, this will still stack along the
  # first axis
  #
  # Arguments
  # *t_array* : Array(Tensor | Enumerable)
  #   `Tensor`s to concatenate
  #
  # Examples
  # --------
  # ```
  # a = [1, 2, 3].to_tensor
  # Num.h_concat([a, a]) # => [1, 2, 3, 1, 2, 3]
  #
  # b = [[1, 2], [3, 4]].to_tensor
  # Num.h_concat([b, b])
  #
  # # [[1, 2, 1, 2],
  # #  [3, 4, 3, 4]]
  # ```
  def hstack(arrs : Array(Tensor(U, CPU(U)))) forall U
    concatenate(arrs, 1)
  end

  # Stack an array of `Tensor`s in sequence column-wise.  While this
  # method can take `Tensor`s with any number of dimensions, it makes
  # the most sense with rank <= 3
  #
  # For one dimensional `Tensor`s, this will still stack along the
  # first axis
  #
  # Arguments
  # *t_array* : Array(Tensor | Enumerable)
  #   `Tensor`s to concatenate
  #
  # Examples
  # --------
  # ```
  # a = [1, 2, 3].to_tensor
  # Num.h_concat([a, a]) # => [1, 2, 3, 1, 2, 3]
  #
  # b = [[1, 2], [3, 4]].to_tensor
  # Num.h_concat([b, b])
  #
  # # [[1, 2, 1, 2],
  # #  [3, 4, 3, 4]]
  # ```
  def hstack(*arrs : Tensor(U, CPU(U))) forall U
    concatenate(arrs.to_a, 1)
  end

  # Repeat elements of a `Tensor`, treating the `Tensor`
  # as flat
  #
  # Arguments
  # ---------
  # - `a` : Tensor | Enumerable
  #   Object to repeat
  # - `n` : Int
  #   Number of times to repeat
  #
  # Examples
  # ```
  # a = [1, 2, 3]
  # Num.repeat(a, 2) # => [1, 1, 2, 2, 3, 3]
  # ```
  def repeat(a : Tensor(U, CPU(U)), n : Int)
  end

  # Repeat elements of a `Tensor` along an axis
  #
  # Arguments
  # ---------
  # - `a` : Tensor | Enumerable
  #   Object to repeat
  # - `n` : Int
  #   Number of times to repeat
  # - `axis` : Int
  #   Axis along which to repeat
  #
  # Examples
  # --------
  # ```
  # a = [[1, 2, 3], [4, 5, 6]]
  # Num.repeat(a, 2, 1)
  #
  # # [[1, 1, 2, 2, 3, 3],
  # #  [4, 4, 5, 5, 6, 6]]
  # ```
  def repeat(a : Tensor(U, CPU(U)), n : Int, axis : Int)
  end

  # Tile elements of a `Tensor`
  #
  # Arguments
  # ---------
  # - `a` : Tensor | Enumerable
  #   Argument to tile
  # - `n` : Int
  #   Number of times to tile
  #
  # Examples
  # --------
  # ```
  # a = [[1, 2, 3], [4, 5, 6]]
  # puts Num.tile(a, 2)
  #
  # # [[1, 2, 3, 1, 2, 3],
  # #  [4, 5, 6, 4, 5, 6]]
  # ```
  def tile(a : Tensor(U, CPU(U)), n : Int) forall U
  end

  # Tile elements of a `Tensor`
  #
  # Arguments
  # ---------
  # - `a` : Tensor | Enumerable
  #   Argument to tile
  # - `n` : Int
  #   Number of times to tile
  #
  # Examples
  # --------
  # ```
  # a = [[1, 2, 3], [4, 5, 6]]
  # puts Num.tile(a, 2)
  #
  # # [[1, 2, 3, 1, 2, 3],
  # #  [4, 5, 6, 4, 5, 6]]
  # ```
  def tile(a : Tensor(U, CPU(U)), n : Array(Int)) forall U
  end

  # Flips a `Tensor` along all axes, returning a view
  #
  # Arguments
  # ---------
  # - `a` : Tensor | Enumerable
  #   Argument to flip
  #
  # Examples
  # --------
  # ```
  # a = [[1, 2, 3], [4, 5, 6]]
  # puts Num.flip(a)
  #
  # # [[6, 5, 4],
  # #  [3, 2, 1]]
  # ```
  def flip(a : Tensor(U, CPU(U))) forall U
    i = [{..., -1}] * a.rank
    a[i]
  end

  # Flips a `Tensor` along an axis, returning a view
  #
  # Arguments
  # ---------
  # - `a` : Tensor | Enumerable
  #   Argument to flip
  # - `axis` : Int
  #   Axis to flip
  #
  # Examples
  # --------
  # ```
  # a = [[1, 2, 3], [4, 5, 6]]
  # puts Num.flip(a, 1)
  #
  # # [[3, 2, 1],
  # #  [6, 5, 4]]
  # ```
  def flip(a : Tensor(U, CPU(U)), axis : Int) forall U
    s = (0...a.rank).map do |i|
      i == axis ? {..., -1} : (...)
    end
    a[s]
  end
end