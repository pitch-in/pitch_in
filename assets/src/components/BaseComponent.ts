export default class BaseComponent {
  public data: any;

  constructor(public element) {
    this.data = element.data();
  }

  static selector: string;
}
