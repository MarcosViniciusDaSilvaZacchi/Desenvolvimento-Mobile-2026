import 'dart:math';

enum ColorStyle { emoji, none }
const colorStyle = ColorStyle.emoji;

String paint(String txt, {required bool isEight, required Suit suit}) {
  if (colorStyle == ColorStyle.none) return txt;
  if (isEight) return '🟩$txt';
  final isRed = suit == Suit.hearts || suit == Suit.diamonds;
  return isRed ? '🟥$txt' : '⬜$txt';
}

enum Suit { spades, hearts, diamonds, clubs }

String suitSymbol(Suit s) =>
    {Suit.spades: '♠', Suit.hearts: '♥', Suit.diamonds: '♦', Suit.clubs: '♣'}[s]!;

// 1. Card
class Card {
  final String rank; // Define a variável para armazenar o valor da carta (ex: 'A', '10', 'K')
  final Suit suit;   // Define a variável para armazenar o naipe da carta usando o Enum Suit

  // Construtor que inicializa a carta exigindo a passagem do valor e do naipe
  Card(this.rank, this.suit); 

  // Getter que retorna 'true' automaticamente se o valor (rank) da carta for igual a '8'
  bool get isEight => rank == '8'; 

  // Mantido: função de exibição com “cores” (não alterar).
  String disp() => paint('$rank${suitSymbol(suit)}', isEight: isEight, suit: suit);
}

// 2. Deck
class Deck {
  final _r = Random();
  final List<Card> _cards = [];

  Deck() {
    // Cria uma lista constante com todos os 13 valores possíveis de um baralho tradicional
    final ranks = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']; 
    
    // Inicia um laço de repetição que vai passar por todos os 4 naipes do Enum Suit
    for (var suit in Suit.values) { 
      // Dentro de cada naipe, inicia outro laço para passar pelos 13 valores
      for (var rank in ranks) { 
        // Instancia um novo objeto Card (combinando o rank e suit atuais) e adiciona à lista _cards
        _cards.add(Card(rank, suit)); 
      } // Fim do laço de valores
    } // Fim do laço de naipes
    
    // Usa o método nativo shuffle com o gerador randomico para embaralhar a lista de cartas prontas
    _cards.shuffle(_r); 
  }

  bool get isEmpty => _cards.isEmpty;

  Card draw() {
    // Verifica se a lista de cartas está vazia antes de tentar comprar
    if (isEmpty) {
      // Se estiver vazia, lança uma exceção para evitar que o programa trave tentando ler o que não existe
      throw Exception('Baralho vazio!'); 
    }
    // Remove a última carta da lista (simulando o topo do monte) e a retorna para quem chamou a função
    return _cards.removeLast(); 
  }

  void addAllAndShuffle(Iterable<Card> cards) {
    // Pega todas as cartas recebidas (geralmente a pilha de descarte) e adiciona no final do baralho atual
    _cards.addAll(cards); 
    // Chama novamente o método de embaralhar para que a recarga do baralho fique aleatória
    _cards.shuffle(_r); 
  }
}

class Player {
  final String name;
  final List<Card> hand = [];
  Player(this.name);

  // Mantido: exibe a mão como texto (não alterar).
  String handDisp() => '[ ${hand.map((c) => c.disp()).join(' ')} ] (${hand.length})';
}

class CrazyEights {
  final List<Player> players = [Player('P1'), Player('P2'), Player('P3'), Player('P4')];
  final Deck deck = Deck();
  final List<Card> discard = [];
  final _rng = Random();

  Suit? requiredSuit;

  // 3. CrazyEights.dealInitial()
  void dealInitial() {
    // Laço que passa por cada um dos 4 objetos Player na lista de jogadores
    for (var p in players) { 
      // Laço interno configurado para repetir exatamente 5 vezes
      for (int i = 0; i < 5; i++) { 
        // Adiciona à lista "hand" (mão) do jogador atual uma carta puxada do topo do baralho
        p.hand.add(deck.draw()); 
      } // Fim da distribuição para o jogador atual
    } // Fim do laço de jogadores
    
    // Puxa mais uma carta do baralho e a coloca na lista de descarte para iniciar a mesa
    discard.add(deck.draw()); 
    
    // Verifica usando o getter isEight se a carta inicial que virou na mesa é o coringa
    if (top.isEight) { 
      // Se for um 8, sorteia um número de 0 a 3 e usa como índice para definir um naipe obrigatório inicial
      requiredSuit = Suit.values[_rng.nextInt(4)]; 
    } // Fim do if
  }

  // 4. CrazyEights.top (getter)
  Card get top {
    // Acessa a lista de descarte e retorna o último elemento, que visualmente é o "topo" da pilha
    return discard.last; 
  }

  // 5. CrazyEights.isPlayable(Card c)
  bool isPlayable(Card c) {
    // Pela regra oficial do Oito Maluco, se a carta for um 8, ela sempre pode ser jogada
    if (c.isEight) return true; 
    
    // Verifica se a variável requiredSuit não é nula (alguém jogou um 8 antes e exigiu um naipe)
    if (requiredSuit != null) { 
      // Se um naipe foi exigido, a carta avaliada só pode ser jogada se tiver o exato mesmo naipe
      return c.suit == requiredSuit; 
    } // Fim da checagem de coringa anterior
    
    // Se não há exigência de 8, a carta pode ser jogada se seu naipe OU seu valor baterem com a carta do topo
    return c.suit == top.suit || c.rank == top.rank; 
  }

  // 6. CrazyEights.chooseSuitForEight(Player p)
  Suit chooseSuitForEight(Player p) {
    // Cria um dicionário (Map) vazio para contabilizar a quantidade de cada naipe que o jogador tem
    Map<Suit, int> counts = {}; 
    
    // Inicia um laço para analisar carta por carta na mão do jogador
    for (var card in p.hand) { 
      // Ignora as cartas 8 na contagem, pois o objetivo é escolher o melhor naipe normal
      if (!card.isEight) { 
        // Incrementa o contador daquele naipe específico. O '?? 0' garante que inicie em 0 se for a primeira vez
        counts[card.suit] = (counts[card.suit] ?? 0) + 1; 
      } // Fim do if
    } // Fim do laço
    
    // Se o jogador só tiver coringas na mão (mapa vazio), chuta um naipe aleatório para não travar
    if (counts.isEmpty) return Suit.values[_rng.nextInt(4)]; 
    
    // Pega temporariamente o primeiro naipe encontrado no mapa para ter um ponto de comparação inicial
    var bestSuit = counts.keys.first; 
    
    // Laço para comparar a quantidade de todos os naipes que foram contabilizados
    for (var suit in counts.keys) { 
      // Verifica se o naipe atual do laço tem uma contagem maior que o naipe armazenado em bestSuit
      if (counts[suit]! > counts[bestSuit]!) { 
        // Se for maior, atualiza a variável bestSuit para registrar este novo naipe como o melhor
        bestSuit = suit; 
      } // Fim do if
    } // Fim da comparação
    
    // Retorna o naipe que apareceu mais vezes na mão do jogador
    return bestSuit; 
  }

  // 7. CrazyEights.refillDeckIfNeeded()
  void refillDeckIfNeeded() {
    // Checa duas condições: se o baralho de compras acabou e se há mais de uma carta no monte de descarte
    if (deck.isEmpty && discard.length > 1) { 
      // Salva a carta do topo e a remove do descarte, para que ela não seja embaralhada
      final topCard = discard.removeLast(); 
      // Chama o método do baralho mandando todo o restante da pilha de descarte para ser embaralhado
      deck.addAllAndShuffle(discard); 
      // Limpa a lista de descarte atual, já que as cartas foram transferidas fisicamente para o baralho
      discard.clear(); 
      // Devolve a carta salva de volta para a lista de descarte, mantendo a mesa como estava
      discard.add(topCard); 
    } // Fim da recarga
  }

  // 8. CrazyEights.chooseCardToPlay(Player p)
  Card? chooseCardToPlay(Player p) {
    // Cria uma lista vazia temporária apenas para guardar quais cartas da mão atual obedecem às regras
    List<Card> validCards = []; 
    
    // Laço para testar cada carta da mão do jogador
    for (var card in p.hand) { 
      // Envia a carta para a função isPlayable; se retornar true, a carta é adicionada na lista de válidas
      if (isPlayable(card)) validCards.add(card); 
    } // Fim da validação da mão
    
    // Se a lista de cartas válidas continuar vazia, retorna null indicando que o jogador precisará comprar
    if (validCards.isEmpty) return null; 
    
    // Laço que prioriza jogar cartas normais antes de gastar um coringa
    for (var card in validCards) { 
      // Se a carta válida não for um 8, ela é escolhida e a função encerra retornando ela
      if (!card.isEight) return card; 
    } // Fim da busca por cartas normais
    
    // Se o laço anterior não retornou nada, significa que as únicas opções válidas são coringas (8), então retorna o primeiro
    return validCards.first; 
  }

  // 9. CrazyEights.run()
  void run() {
    // Chama a função inicial que dá 5 cartas pra cada um e vira a carta do descarte
    dealInitial(); 
    // Mostra como a mesa ficou logo após a distribuição inicial
    printState(); 
    
    // Define um limite máximo de turnos de segurança para impedir que a simulação trave num laço infinito
    int maxTurns = 1000; 
    // Inicia um contador de turnos no zero
    int turnCount = 0; 
    // Define o índice 0 (Jogador 1) como o primeiro a jogar
    int currentPlayerIndex = 0; 

    
    // Loop principal do jogo que continua rodando enquanto o limite de segurança não for atingido
    while (turnCount < maxTurns) { 
      // Extrai o objeto Player correspondente ao índice atual para facilitar a manipulação no código
      Player p = players[currentPlayerIndex]; 
      
      // Imprime o cabeçalho do turno informando de quem é a vez e qual carta está no topo
      print('\n--- Vez de ${p.name} --- Topo: ${top.disp()}'); 
      
      // Chama a estratégia do jogador para decidir qual carta jogar, podendo retornar uma Carta ou null
      Card? toPlay = chooseCardToPlay(p); 
      
      // Laço While para a fase de compra: ocorre sempre que a escolha inicial for nula (sem carta jogável)
      while (toPlay == null) { 
        // Antes de tentar comprar, verifica se precisa reembaralhar o lixo de volta pro monte
        refillDeckIfNeeded(); 
        
        // Se mesmo após tentar recarregar o baralho continuar vazio, quebra o laço de compras para não travar
        if (deck.isEmpty) break; 
        
        // Remove uma carta do baralho e a armazena numa variável temporária 'drawn'
        Card drawn = deck.draw(); 
        // Adiciona a carta comprada fisicamente na mão do jogador
        p.hand.add(drawn); 
        // Imprime no console a ação de compra para acompanhamento da simulação
        print('${p.name} comprou ${drawn.disp()}'); 
        
        // Após comprar, roda a estratégia novamente para ver se a nova carta permite fazer uma jogada
        toPlay = chooseCardToPlay(p); 
        
        // Se ele achou uma carta agora, imprime a mensagem específica informando que vai jogá-la
        if (toPlay != null) {
          print('${p.name} vai jogar a carta recém-comprada.'); 
        }
      } // Fim da fase de compra

      // Se passou da fase de compras e tem uma carta definida para jogar
      if (toPlay != null) { 
        // Remove a carta escolhida da mão do jogador definitivamente
        p.hand.remove(toPlay); 
        // Coloca a carta escolhida no topo da pilha de descarte da mesa
        discard.add(toPlay); 
        
        // Verifica se a carta que acabou de ser jogada é o coringa (8)
        if (toPlay.isEight) { 
          // Executa a estratégia para o jogador escolher o melhor naipe e salva na variável global requiredSuit
          requiredSuit = chooseSuitForEight(p); 
          // Imprime que a carta foi jogada e avisa qual foi o naipe exigido
          print('${p.name} jogou ${toPlay.disp()} e DECLAROU naipe: 🟩${suitSymbol(requiredSuit!)}'); 
        } else { 
          // Se for uma carta normal, limpa qualquer exigência de naipe que houvesse antes
          requiredSuit = null; 
          // Imprime a ação simples de descarte da carta
          print('${p.name} jogou ${toPlay.disp()}'); 
        } // Fim da checagem do 8 no descarte
      } else { 
        // Bloco executado apenas se o baralho zerou completamente e o jogador ficou travado
        print('${p.name} passou a vez por falta de cartas no baralho.'); 
      } // Fim da fase de descarte

      // Imediatamente após a jogada, verifica se a mão do jogador atual zerou
      if (p.hand.isEmpty) { 
        // Se a mão zerou, imprime o status atual da mesa para provar a vitória
        printState(); 
        // Imprime a mensagem de fim de jogo comemorando a vitória do jogador atual
        print('>>> ${p.name} venceu! Ficou sem cartas.'); 
        // Encerra imediatamente o método run(), finalizando a simulação
        return; 
      } // Fim do check de vitória

      // Se ninguém venceu ainda, mostra como a mesa ficou no final deste turno
      printState(); 
      
      // Atualiza o índice do jogador atual. O uso de módulo (%) garante que ao passar de 3 (P4) ele volte para 0 (P1)
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length; 
      // Incrementa o contador de turnos gerais para a trava de segurança
      turnCount++; 
    } // Fim do loop principal
    
    // Se o laço for quebrado pelo maxTurns, avisa que a partida foi encerrada por segurança
    print('A simulação foi interrompida (limite de turnos atingido). Empate!'); 
  }

  void printState() {
    print('\nEstado atual:');
    for (final p in players) {
      print('  ${p.name}: ${p.handDisp()}');
    }
    final reqStr = (requiredSuit != null) ? ' (naipe declarado: 🟩${suitSymbol(requiredSuit!)})' : '';
    // Substituindo <TOPO> pelo topo real da pilha de descartes usando a propriedade top que criamos
    print('  Descarte (topo): ${top.disp()}$reqStr');
  }
}

void main() {
  print('=== Oito Maluco — Simulação automática (4 jogadores) ===');
  print('Legenda: vermelhas (🟥), brancas (⬜), coringa (🟩).');
  
  // Chama o objeto principal e inicia a simulação do jogo com a função run() construída no TODO 9
  CrazyEights().run(); 
}