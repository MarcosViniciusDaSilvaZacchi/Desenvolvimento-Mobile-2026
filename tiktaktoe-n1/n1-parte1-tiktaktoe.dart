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
   
    int row = int.parse(stdin.readLineSync()!);
    int col = int.parse(stdin.readLineSync()!);

    // TODO 1:
    // Verificar se a posição escolhida é válida e está vazia.
    // Se não for válida, mostrar mensagem e continuar o loop.

if (row < 0 || row > 2 || col < 0 || col > 2) {
      print('Entrada inválida! Escolha números entre 0 e 2 para linha e coluna.');
      continue; // Faz o loop voltar para o início e pedir os números de novo
    }

    // Verificar se a posição no tabuleiro está vazia (contém apenas um espaço ' ')
    if (board[row][col] != ' ') {
      print('Essa posição já está ocupada por um ${board[row][col]}! Escolha outra.');
      continue; // Faz o loop voltar para o início
    }

    // TODO 2:
    // Registrar a jogada no tabuleiro.

    // TODO 3:
    // Verificar se o jogador atual venceu.
    // Se venceu, exibir mensagem e encerrar o jogo.

    // TODO 4:
    // Verificar se houve empate.
    // Se empate, exibir mensagem e encerrar o jogo.

    // TODO 5:
    // Alternar o jogador (X <-> O)
  }

  clearScreen();
  drawBoard(board);
  print('Fim de jogo!');
}

void drawBoard(List<List<String>> board) {
  print('  0   1   2');
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

  return false;
}

bool checkDraw(List<List<String>> board) {
  // TODO 7:
  // Retornar true se todas as posições estiverem preenchidas.
  return false;
}
