abstract class MainScreenEvent{}

class TabChangeEvent extends MainScreenEvent{
  final int index;
  TabChangeEvent(this.index);
}