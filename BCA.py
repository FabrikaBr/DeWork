def bca_sort(arr):
    """
    Algoritmo de ordenação Bubble Cocktail Sort (BCA)
    :param arr: uma lista de números a ser ordenada
    """
    n = len(arr) # Obtém o tamanho da lista
    swapped = True # Define swapped como True para iniciar o loop while

    while swapped:
        swapped = False # Define swapped como False antes de iniciar o loop for

        # Loop for para percorrer do início ao fim do array
        for i in range(n-1):
            # Compara o elemento atual com o próximo elemento
            if arr[i] > arr[i+1]:
                # Se o elemento atual for maior do que o próximo, troca os dois
                arr[i], arr[i+1] = arr[i+1], arr[i]
                swapped = True # Define swapped como True, pois ocorreu uma troca

        # Se não houver trocas no primeiro loop, a lista está ordenada
        if not swapped:
            break

        swapped = False # Define swapped como False antes de iniciar o segundo loop

        # Loop for para percorrer do fim ao início do array
        for i in range(n-1, 0, -1):
            # Compara o elemento atual com o elemento anterior
            if arr[i] < arr[i-1]:
                # Se o elemento atual for menor do que o elemento anterior, troca os dois
                arr[i], arr[i-1] = arr[i-1], arr[i]
                swapped = True # Define swapped como True, pois ocorreu uma troca
