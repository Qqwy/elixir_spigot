defmodule Spigot.Moebius do
  alias __MODULE__, as: M
  use Ratio

  @moduledoc """
  This is known as a Linear Fractional Transformation or Möbius transformation.
  It is used to describe any transformations.
  """

  @doc """
  Internally represented by a quadruple.

  This represents the transformation

  z(x) = qx + r / sx + t
  """
  defstruct [trans: {1,0,0,1}]

  def new(q,r,s,t) do
    %M{trans: {q,r,s,t}}
  end

  def extr(%__MODULE__{trans: {q,r,s,t}}, x) do
    (q * x + r) / (s * x + t)
  end

  def unit do
    %M{trans: {1,0,0,1}}
  end

  # Same as matrix multiplication
  def comp(_a = %M{trans: {q,r,s,t}}, _b = %M{trans: {u,v,w,x}}) do
    %M{trans: {q * u + r * w, q * v + r * x, s * u + t * w, s * v + t * x}}
  end
end
