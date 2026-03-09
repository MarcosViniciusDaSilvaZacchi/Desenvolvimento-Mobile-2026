import 'dart:io';

void main() {
  List<List<String>> board = List.generate(
    3,
    (_) => List.generate(3, (_) => ' '),
  );

  String currentPlayer = 'X';
  bool gameOver = false;

  while (!gameOver) {
    clearScreen();
    drawBoard(board);

    print('Jogador $currentPlayer, escolha linha e coluna (0, 1 ou 2):');
    
    // RACIOCÍNIO: Leitura de dados do console
    int row = int.parse(stdin.readLineSync()!);
    int col = int.parse(stdin.readLineSync()!);

    // TODO 1:
    // Verificar se a posição escolhida é válida e está vazia.
    // Se não for válida, mostrar mensagem e continuar o loop.
    if (row < 0 || row > 2 || col < 0 || col > 2) {
      print('Entrada inválida! Escolha números entre 0 e 2 para linha e coluna.');
      sleep(Duration(seconds: 2)); // Pausa para leitura
      continue; // Faz o loop voltar para o início 
    }

    // Verificar se a posição no tabuleiro está vazia (contém apenas um espaço ' ')
    if (board[row][col] != ' ') {
      print('Essa posição já está ocupada por um ${board[row][col]}! Escolha outra.');
      sleep(Duration(seconds: 2));
      continue; // Faz o loop voltar para o início
    }

    // TODO 2:
    // Registrar a jogada no tabuleiro.
    board[row][col] = currentPlayer;

    // TODO 3:
    // Verificar se o jogador atual venceu.
    // Se venceu, exibir mensagem e encerrar o jogo.
    if (checkWinner(board, currentPlayer)) {
      clearScreen();
      drawBoard(board);
      print('\nParabéns! O jogador $currentPlayer venceu!');
      gameOver = true;
    } 
    // TODO 4:
    // Verificar se houve empate.
    // Se empate, exibir mensagem e encerrar o jogo.
    else if (checkDraw(board)) {
      clearScreen();
      drawBoard(board);
      print('\nO jogo empatou (Velha)!');
      gameOver = true;
    } 
    // TODO 5:
    // Alternar o jogador (X <-> O)
    else {
      // Uso do operador ternário para alternância
      currentPlayer = (currentPlayer == 'X') ? 'O' : 'X';
    }
  }

  print('Fim de jogo!');
}

void drawBoard(List<List<String>> board) {
  print('   0   1   2');
  for (int i = 0; i < 3; i++) {
    print('${i} ${board[i][0]} | ${board[i][1]} | ${board[i][2]}');
    if (i < 2) print(' ---+---+---');
  }
}

void clearScreen() {
  // Simula limpeza do console 
  print('\x1B[2J\x1B[0;0H');
}

bool checkWinner(List<List<String>> board, String player) {
  // TODO 6:
  // Implementar verificação de vitória:
  // - 3 linhas
  // - 3 colunas
  // - 2 diagonais
  
  // RACIOCÍNIO: Verificação de Linhas e Colunas usando operadores lógicos 
  for (int i = 0; i < 3; i++) {
    if (board[i][0] == player && board[i][1] == player && board[i][2] == player) return true;
    if (board[0][i] == player && board[1][i] == player && board[2][i] == player) return true;
  }
  
  // Verificar Diagonais
  if (board[0][0] == player && board[1][1] == player && board[2][2] == player) return true;
  if (board[0][2] == player && board[1][1] == player && board[2][0] == player) return true;

  return false;
}

bool checkDraw(List<List<String>> board) {
  // TODO 7:
  // Retornar true se todas as posições estiverem preenchidas.
  for (var row in board) {
    if (row.contains(' ')) return false; // Ainda há espaço vazio
  }
  return true; // Se percorreu tudo e não achou espaço, é empate
}