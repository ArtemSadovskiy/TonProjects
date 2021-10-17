pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract TaskList {

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }
    
    struct task {
        string caseName;
        uint256 timeOfAddition;
        bool completionOfTheCase;
    }
    

    mapping (uint8=>task) public listTask;
    string[] public tasks;
    uint8[] public numTasks;
    uint8 public numberTask;
    uint8 public size;

    modifier checkOwnerAndAccept {
		// Check that message was signed with contracts key.
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

    function newTask(string calldata caseName) public checkOwnerAndAccept{
        numberTask++;
        size++;
        task memory newTask = task(caseName, block.timestamp, false);
        numTasks.push(numberTask);
        tasks.push(newTask.caseName);
        listTask[numberTask] = newTask;
    }
    
    function getQuantityOpenTasks() public view checkOwnerAndAccept returns(uint8){
        return size;
    }
    
    function getListTask() public view checkOwnerAndAccept returns (string[] memory) {
        return tasks;
    }
    
    function getTask(uint8 numberTask) public view checkOwnerAndAccept returns (string memory caseName, uint256 timeOfAddition, bool completionOfTheCase) {
        return (listTask[numberTask].caseName, listTask[numberTask].timeOfAddition, listTask[numberTask].completionOfTheCase);
    }
    
    function deletTask(uint8 numberTask) public checkOwnerAndAccept returns(string[] memory){
        size--;
        delete listTask[numberTask];
        for (uint i = 0; i < numTasks.length; i++){
            if(numTasks[i] == numberTask){
                for(uint j = i; j < tasks.length-1; j++){
                    numTasks[j] = numTasks[j+1];
                    tasks[j] = tasks[j+1];
                }
                tasks.pop();
                numTasks.pop();
            }
        }
        return tasks;
    }
    
    function taskCompleted(uint8 numberTask) public checkOwnerAndAccept{
        listTask[numberTask].completionOfTheCase = true;
    }
}
