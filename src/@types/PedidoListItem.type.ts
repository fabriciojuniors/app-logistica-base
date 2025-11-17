export type PedidoListItem = {
    id: string;
    data?: string;
    localizacao: string;
    status: string;
    itens_pedido?: Array<{ quantidade: number }>;
};