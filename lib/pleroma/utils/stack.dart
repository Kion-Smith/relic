class Stack<E>
{
  StackNode? _tail;

  void push(E data)
  {
    if(_tail == null)
    {
      _tail = StackNode(data, null);
    }
    else
    {
      StackNode temp = StackNode(data, _tail);
      _tail = temp;
    }
  }

  E pop()
  {
    if(_tail != null)
    {
      E curData = _tail?.getData();
      _tail = _tail?.getPrev();
      return curData;
    }
    else
    {
      throw Exception("Cannot pop stack as it is already empty");
    }
  }

  E peek()
  {
    if(_tail != null)
    {
      return _tail?.getData();
    }

    throw Exception("Cannot peek stack as it is empty");
  }

  bool isEmpty() => _tail == null;
  
}

class StackNode<E>
{
  final E _data;
  final StackNode? _prev;

  StackNode(this._data, this._prev);

  E getData() => _data;
  StackNode? getPrev() => _prev;
}
