Project
===

Common requirements
---

- Program must (in rare occasions should) implement distributed symmetric algorithm.
- Nodes must have an interactive and a batch mode.
- Nodes must log their progress (into console and into log files)
- Log entries must have timestamp (ideally physical and logical time)
- Each node must have unique identification (use of IP and port is recommended)

Examples of work assignments
---

- **Chat**
  - Program will allow users (nodes) to send messages to each other. All messages must have full ordering (for synchronization use leader or mutual exclusion). All nodes must have at least these functions: send message, login, logout, crash (exit without logout).
- **Shared variable/memory**
  - Program will allow users (nodes) to access shared variable/block of memory. Access mechanism should be realized via leader or mutual exclusion. All nodes must have at least these functions: read/write variable/memory, login, logout, crash (exit without logout).
- **Deadlock detection**
  - Program will allow nodes to detect if there is a deadlock in the network (you can choose between deadlock on resources or deadlock on communication). Alternatively You can use apriori methods and avoid deadlock state.
- **Termination detection**
  - Program will allow nodes to detect termination of some algorithm (You can simulate computation on nodes by waiting). Computation can be started on any node. Each node must be able to ask for more work. Each node must be able to share it's work to any other node.

Specification of work assignments
---

- Specification of the work must be sent on email (peter.macejko@fel.cvut.cz) till 9.12.2014.
  - Specification must specify:
    - function (chat, variable sharing, …)
    - problem class (leader election, termination detection, …)
    - algorithm (Chang-Roberts, …)
    - framework used (Java-RMI, CORBA, own, …)

Submission
---

- Fully working program must be send on email (peter.macejko@fel.cvut.cz) till 12.1.2015.
- Penalization for late submission:
  - 0-10min -- 5%
  - 10min-9hrs -- 15%
  - 9hrs-7days -- 40%
  - 7days-14days -- 80%
  - 14days+ -- 100%

