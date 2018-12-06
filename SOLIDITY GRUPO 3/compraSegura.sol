pragma solidity ^0.4.0;
contract Purchase {
    uint public value; // Valor de la compra
    address public seller; // Dirección del vendedor
    address public buyer; // Dirección del comprador
// Estados: Creado - Bloqueado - Finalizado)
    enum State { Created, Locked, Inactive }
    State public state;
	
function Purchase() public payable {
    seller = msg.sender;
    value = msg.value / 2;
    require((2 * value) == msg.value);
}
    modifier condition(bool _condition) {
        require(_condition);
        _;
    }
    modifier onlyBuyer() {
        require(msg.sender == buyer);
        _;
    }
	    modifier onlySeller() {
        require(msg.sender == seller);
        _;
    }
    modifier inState(State _state) {
        require(state == _state);
        _;
    }
	
	event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();
	
    function abort()
        public
        onlySeller
        inState(State.Created)
    {
        emit Aborted();
        state = State.Inactive;
        seller.transfer(this.balance);
    }
	
	    function confirmPurchase()
        public
        inState(State.Created)
        condition(msg.value == (2 * value))
        payable
    {
        emit PurchaseConfirmed();
        buyer = msg.sender;
        state = State.Locked;
    }
	
	    function confirmReceived()
        public
        onlyBuyer
        inState(State.Locked)
    {
        emit ItemReceived();
        state = State.Inactive;
        buyer.transfer(value);
        seller.transfer(this.balance);
    }
}