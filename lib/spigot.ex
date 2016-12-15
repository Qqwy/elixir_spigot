defmodule Spigot do


  @doc """
  This produces an infinite list of output terms.
  `inputTermList` is a list of input terms.
  `state` is an initial state that is updated during each iteration of the algorithm.

  From each state, the algorithm calls `nextState = updateStateFun.(state)`.
  if `isSafeFun.(nextState)` is true:
   `actualNextState = productionFun.(nextState)` is called to adjust the state for the next iteration, after which `nextState` is returned,
   and then `nextState` is added as output.
  If it is not, `consumeFun.(state, x)` is called, where `x` is the next term in `inputTermStream`
  that has not yet been consumed.


  The idea is that the state always keeps an invariant true during each iteration.
  """
  def stream(updateStateFun, isSafeFun, productionFun, consumeFun, initialState, inputTermStream) do
    {:discard, updateStateFun, isSafeFun, productionFun, consumeFun, initialState, inputTermStream}
    |> Stream.iterate(&stream_iteration/1)
    |> Stream.take_while(fn septuple -> elem(septuple, 0) != :done   end)
    |> Stream.filter_map(fn septuple -> is_number(elem(septuple, 0)) end,
                         fn septuple ->           elem(septuple, 0)  end)
  end


  # This is the iteration that is called 'lazily' by using Stream.iterate/1.
  # Because results are only available 'sometimes', clearly indicates
  # when the result is intermediate or final.
  #
  # Translation of the Haskell version written in `Unbounded Spigot Algorithms for the Digits of Pi`
  # by Jemery Gibbons, http://www.cs.ox.ac.uk/people/jeremy.gibbons/publications/spigot.pdf, Section 4.
  # @spec stream_iteration((b->c), (b->c->boolean), (b->c->b, (b->a->b), b, [a])) :: [c]
  defp stream_iteration({_finaldigit, updateStateFun, isSafeFun, productionFun, consumeFun, state, inputTermStream}) do
    nextState = updateStateFun.(state)
    if isSafeFun.(state, nextState) do
      {nextState, updateStateFun, isSafeFun, productionFun, consumeFun, productionFun.(state, nextState), inputTermStream}
    else
      case Enum.take(inputTermStream, 1) do
        [inputTerm] ->
          {:intermediate, updateStateFun, isSafeFun, productionFun, consumeFun, consumeFun.(state, inputTerm), Stream.drop(inputTermStream, 1)}
        [] ->
          # We've reached the end of the inputTermStream. Indicate we do not want to keep iterating by writing an :done as first argument.
          {:done, updateStateFun, isSafeFun, productionFun, consumeFun, state, inputTermStream}
    end
    end
  end

  # TODO: Use Ratio (without the autoconversion).
  def convert({base1, base2}, inputStream) do
    initialState   =    {0.0, 1.0}
    updateStateFun = fn {u, v}            -> Float.floor(u * v * base2) end
    isSafeFun      = fn {u, v}, nextState -> nextState == Float.floor((u+1) * v * base2) end
    productionFun  = fn {u, v}, nextState -> {u - (nextState / (v * base2)), (v * base2)} end
    consumeFun     = fn {u, v}, inputTerm -> {inputTerm + u * base1        ,  v / base1 } end
    stream(
      updateStateFun,
      isSafeFun,
      productionFun,
      consumeFun,
      initialState,
      inputStream
    )
  end
end