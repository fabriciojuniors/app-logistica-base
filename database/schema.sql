-- ========================================
-- Schema para Sistema de Logística
-- ========================================

-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ========================================
-- Tabela: produtos
-- ========================================
CREATE TABLE IF NOT EXISTS public.produtos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    imagem TEXT, -- Caminho da imagem no storage do Supabase (ex: produtos/produto-1.jpg)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Adicionar código de barras (barcode) aos produtos
ALTER TABLE public.produtos
ADD COLUMN IF NOT EXISTS codigo_barras VARCHAR(255);

-- ========================================
-- Tabela: pedidos
-- ========================================
CREATE TABLE IF NOT EXISTS public.pedidos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    data TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    localizacao TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pendente',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraint para validar status
    CONSTRAINT pedidos_status_check CHECK (
        status IN ('pendente', 'em_preparacao', 'pronto', 'em_entrega', 'entregue', 'cancelado')
    )
);

-- Incluir coluna do entregador (usuário do Supabase Auth)
ALTER TABLE public.pedidos
ADD COLUMN IF NOT EXISTS entregador_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- ========================================
-- Tabela: itens_pedido
-- ========================================
CREATE TABLE IF NOT EXISTS public.itens_pedido (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pedido_id UUID NOT NULL REFERENCES public.pedidos(id) ON DELETE CASCADE,
    produto_id UUID NOT NULL REFERENCES public.produtos(id) ON DELETE RESTRICT,
    quantidade INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraint para validar quantidade positiva
    CONSTRAINT itens_pedido_quantidade_check CHECK (quantidade > 0)
);

-- ========================================
-- Tabela: entregas
-- ========================================
CREATE TABLE IF NOT EXISTS public.entregas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pedido_id UUID NOT NULL REFERENCES public.pedidos(id) ON DELETE CASCADE,
    id_integrador UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    data_hora_entrega TIMESTAMP WITH TIME ZONE,
    coordenadas_lat DECIMAL(10, 8),
    coordenadas_lng DECIMAL(11, 8),
    status VARCHAR(50) NOT NULL DEFAULT 'aguardando',
    data_hora_inicio_rota TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraint para validar status
    CONSTRAINT entregas_status_check CHECK (
        status IN ('aguardando', 'em_rota', 'entregue', 'cancelada')
    )
);

-- ========================================
-- Alterações na tabela entregas (novos campos)
-- ========================================
-- Adicionar campo de observações
ALTER TABLE public.entregas 
ADD COLUMN IF NOT EXISTS observacoes TEXT;

-- Adicionar campo para registrar quem recebeu a entrega
ALTER TABLE public.entregas 
ADD COLUMN IF NOT EXISTS entregue_para VARCHAR(255);

-- ========================================
-- Índices para melhor performance
-- ========================================
CREATE INDEX IF NOT EXISTS idx_pedidos_status ON public.pedidos(status);
CREATE INDEX IF NOT EXISTS idx_pedidos_data ON public.pedidos(data);
CREATE INDEX IF NOT EXISTS idx_itens_pedido_pedido_id ON public.itens_pedido(pedido_id);
CREATE INDEX IF NOT EXISTS idx_itens_pedido_produto_id ON public.itens_pedido(produto_id);
CREATE INDEX IF NOT EXISTS idx_entregas_pedido_id ON public.entregas(pedido_id);
CREATE INDEX IF NOT EXISTS idx_entregas_integrador_id ON public.entregas(id_integrador);
CREATE INDEX IF NOT EXISTS idx_entregas_status ON public.entregas(status);

-- ========================================
-- Funções auxiliares para updated_at
-- ========================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para atualizar updated_at automaticamente
CREATE TRIGGER set_produtos_updated_at
    BEFORE UPDATE ON public.produtos
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_pedidos_updated_at
    BEFORE UPDATE ON public.pedidos
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_itens_pedido_updated_at
    BEFORE UPDATE ON public.itens_pedido
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_entregas_updated_at
    BEFORE UPDATE ON public.entregas
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- ========================================
-- Habilitar Row Level Security (RLS)
-- ========================================
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_pedido ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entregas ENABLE ROW LEVEL SECURITY;

-- ========================================
-- Políticas RLS - Produtos
-- ========================================
-- Todos os usuários autenticados podem ler produtos
CREATE POLICY "Usuários autenticados podem visualizar produtos"
    ON public.produtos
    FOR SELECT
    TO authenticated
    USING (true);

-- ========================================
-- Políticas RLS - Pedidos
-- ========================================
-- Todos os usuários autenticados podem ler pedidos
CREATE POLICY "Usuários autenticados podem visualizar pedidos"
    ON public.pedidos
    FOR SELECT
    TO authenticated
    USING (true);

-- ========================================
-- Políticas RLS - Itens do Pedido
-- ========================================
-- Todos os usuários autenticados podem ler itens do pedido
CREATE POLICY "Usuários autenticados podem visualizar itens do pedido"
    ON public.itens_pedido
    FOR SELECT
    TO authenticated
    USING (true);

-- ========================================
-- Políticas RLS - Entregas
-- ========================================
-- Todos os usuários autenticados podem ler entregas
CREATE POLICY "Usuários autenticados podem visualizar entregas"
    ON public.entregas
    FOR SELECT
    TO authenticated
    USING (true);

-- Usuários autenticados podem inserir entregas
CREATE POLICY "Usuários autenticados podem criar entregas"
    ON public.entregas
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Usuários autenticados podem atualizar entregas
CREATE POLICY "Usuários autenticados podem atualizar entregas"
    ON public.entregas
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Opcionalmente: Usuários podem deletar entregas (remova se não for necessário)
CREATE POLICY "Usuários autenticados podem deletar entregas"
    ON public.entregas
    FOR DELETE
    TO authenticated
    USING (true);

-- Usuários autenticados podem atualizar o status do pedido
CREATE POLICY "Usuários autenticados podem atualizar status do pedido"
    ON public.pedidos
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);    

-- ========================================
-- Configuração do Storage Bucket
-- ========================================
-- Criar bucket para imagens de produtos (execute no Supabase Storage ou via código)
-- O bucket deve ser criado manualmente no painel do Supabase Storage com o nome 'produtos'
-- Configuração recomendada:
-- - Nome: produtos
-- - Público: true (para facilitar acesso às imagens)
-- - Tipos de arquivo permitidos: image/jpeg, image/png, image/webp

-- Políticas de acesso ao bucket 'produtos' (execute após criar o bucket)
-- Nota: As políticas de storage são configuradas separadamente no Supabase

-- ========================================
-- Dados de exemplo - MASSA DE DADOS
-- ========================================

-- Limpar dados anteriores (descomente se quiser resetar)
-- TRUNCATE TABLE public.entregas CASCADE;
-- TRUNCATE TABLE public.itens_pedido CASCADE;
-- TRUNCATE TABLE public.pedidos CASCADE;
-- TRUNCATE TABLE public.produtos CASCADE;

-- ========================================
-- MASSA DE DADOS AJUSTADA COM UUIDs VÁLIDOS
-- ========================================

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================
-- Inserir Produtos
-- ========================================
INSERT INTO public.produtos (id, nome, imagem) VALUES
    ('d3a8c3f2-4c4f-4d4a-8e44-1bb08a19ef10', 'Notebook Dell Inspiron 15', 'produtos/notebook-dell.jpg'),
    ('f2e5bfa1-6711-4203-b13f-9f9a83b673a1', 'Mouse Logitech MX Master 3', 'produtos/mouse-logitech.jpg'),
    ('6b7ccf5d-54d4-41c8-9d3a-cf58ec96f7b2', 'Teclado Mecânico Keychron K2', 'produtos/teclado-keychron.jpg'),
    ('1e5ad5a7-995d-4b6c-b9c7-38c7a59d145b', 'Monitor LG UltraWide 29"', 'produtos/monitor-lg.jpg'),
    ('e238c02a-6a4a-4805-864f-8bde5a7b71c0', 'Headset HyperX Cloud II', 'produtos/headset-hyperx.jpg'),
    ('b1e27e1a-981d-45a7-9f64-f7c7ffb2a94f', 'Webcam Logitech C920', 'produtos/webcam-logitech.jpg'),
    ('c9d1a8f3-8a2e-46e5-9b62-6d7e99ef3f1d', 'SSD Samsung 1TB NVMe', 'produtos/ssd-samsung.jpg'),
    ('dd49a7a1-9071-4b42-8e81-2124c6f5243f', 'Memória RAM Corsair 16GB', 'produtos/ram-corsair.jpg'),
    ('b0b611b8-1e25-4e1e-9e8f-51e0b176a3f2', 'Cadeira Gamer DT3 Sports', 'produtos/cadeira-dt3.jpg'),
    ('f3e70b11-33da-4ce8-a942-7842c4cfaf7a', 'Mesa Digitalizadora Wacom', 'produtos/mesa-wacom.jpg'),
    ('ea7201db-2f3f-4ee2-a9cf-25c8231f6c25', 'Impressora HP LaserJet', 'produtos/impressora-hp.jpg'),
    ('a64e11e1-05a5-4f35-9c51-b4c2e19bfe5b', 'Roteador Wi-Fi 6 TP-Link', 'produtos/roteador-tplink.jpg'),
    ('be79f62f-30f5-4a1f-9310-9d65b6e4158a', 'HD Externo Seagate 2TB', 'produtos/hd-seagate.jpg'),
    ('c0c92f64-b615-4c71-bb07-88b9e4c37da4', 'Cabo HDMI 2.1 Premium 3m', 'produtos/cabo-hdmi.jpg'),
    ('b43a0d09-dc5d-4723-bb49-7e5441cf8a5c', 'Mousepad Gamer RGB XL', 'produtos/mousepad-rgb.jpg')
ON CONFLICT DO NOTHING;

-- ========================================
-- Atualizar produtos com códigos de barras
-- (Exemplos fictícios de códigos de barras)
UPDATE public.produtos SET codigo_barras = '1234567890123' WHERE id = 'd3a8c3f2-4c4f-4d4a-8e44-1bb08a19ef10';
UPDATE public.produtos SET codigo_barras = '2345678901234' WHERE id = 'f2e5bfa1-6711-4203-b13f-9f9a83b673a1';
UPDATE public.produtos SET codigo_barras = '3456789012345' WHERE id = '6b7ccf5d-54d4-41c8-9d3a-cf58ec96f7b2';
UPDATE public.produtos SET codigo_barras = '4567890123456' WHERE id = '1e5ad5a7-995d-4b6c-b9c7-38c7a59d145b';
UPDATE public.produtos SET codigo_barras = '5678901234567' WHERE id = 'e238c02a-6a4a-4805-864f-8bde5a7b71c0';
UPDATE public.produtos SET codigo_barras = '6789012345678' WHERE id = 'b1e27e1a-981d-45a7-9f64-f7c7ffb2a94f';
UPDATE public.produtos SET codigo_barras = '7890123456789' WHERE id = 'c9d1a8f3-8a2e-46e5-9b62-6d7e99ef3f1d';
UPDATE public.produtos SET codigo_barras = '8901234567890' WHERE id = 'dd49a7a1-9071-4b42-8e81-2124c6f5243f';
UPDATE public.produtos SET codigo_barras = '9012345678901' WHERE id = 'b0b611b8-1e25-4e1e-9e8f-51e0b176a3f2';
UPDATE public.produtos SET codigo_barras = '0123456789012' WHERE id = 'f3e70b11-33da-4ce8-a942-7842c4cfaf7a';
UPDATE public.produtos SET codigo_barras = '1123456789012' WHERE id = 'ea7201db-2f3f-4ee2-a9cf-25c8231f6c25';
UPDATE public.produtos SET codigo_barras = '2123456789012' WHERE id = 'a64e11e1-05a5-4f35-9c51-b4c2e19bfe5b';
UPDATE public.produtos SET codigo_barras = '3123456789012' WHERE id = 'be79f62f-30f5-4a1f-9310-9d65b6e4158a';
UPDATE public.produtos SET codigo_barras = '4123456789012' WHERE id = 'c0c92f64-b615-4c71-bb07-88b9e4c37da4';
UPDATE public.produtos SET codigo_barras = '5123456789012' WHERE id = 'b43a0d09-dc5d-4723-bb49-7e5441cf8a5c';

-- ========================================
-- Inserir Pedidos
-- ========================================
INSERT INTO public.pedidos (id, data, localizacao, status) VALUES
    ('b391df0d-0b29-4b9c-a254-0a0c2c0b70ff', '2025-10-28 09:15:00-03', 'Rua das Flores, 123 - Centro, São Paulo - SP', 'entregue'),
    ('a78b8848-fc5e-4a60-907d-f4a3e26ec0b7', '2025-10-28 14:30:00-03', 'Av. Paulista, 1578 - Bela Vista, São Paulo - SP', 'entregue'),
    ('a6e66cd2-9d77-4f45-8d7b-89198a7bb46b', '2025-10-29 10:00:00-03', 'Rua Augusta, 456 - Consolação, São Paulo - SP', 'em_entrega'),
    ('2e2b70b5-63ac-47a8-8a57-4d7dc5b1c7e2', '2025-10-29 11:45:00-03', 'Av. Brigadeiro Faria Lima, 2232 - Jardim Paulistano, São Paulo - SP', 'em_entrega'),
    ('11b49e83-fd6b-4a1a-b537-2b5b9e3854d1', '2025-10-30 08:20:00-03', 'Rua Oscar Freire, 789 - Jardins, São Paulo - SP', 'pronto'),
    ('9fc9e5c3-3f12-48c9-b93e-d60a4f03f8f0', '2025-10-30 13:00:00-03', 'Av. Rebouças, 3970 - Pinheiros, São Paulo - SP', 'pronto'),
    ('b3ee3f9b-bb61-4b93-a74f-1a4a816e354a', '2025-10-31 09:30:00-03', 'Rua Haddock Lobo, 595 - Cerqueira César, São Paulo - SP', 'em_preparacao'),
    ('0e3d7c9a-d3b9-4e8c-8829-b34488e86170', '2025-10-31 15:45:00-03', 'Av. Ibirapuera, 3103 - Moema, São Paulo - SP', 'em_preparacao'),
    ('0836653d-d3ee-46e9-8e5c-776325fc5f03', '2025-11-01 08:00:00-03', 'Rua da Consolação, 3741 - Consolação, São Paulo - SP', 'pendente'),
    ('9a3f1183-5175-4c81-878d-540c3814b0e4', '2025-11-01 10:30:00-03', 'Av. Angélica, 2491 - Consolação, São Paulo - SP', 'pendente')
ON CONFLICT DO NOTHING;

-- ========================================
-- Inserir Itens dos Pedidos
-- ========================================
INSERT INTO public.itens_pedido (id, pedido_id, produto_id, quantidade) VALUES
    -- Pedido 1: Notebook + Mouse
    (uuid_generate_v4(), 'b391df0d-0b29-4b9c-a254-0a0c2c0b70ff', 'd3a8c3f2-4c4f-4d4a-8e44-1bb08a19ef10', 1),
    (uuid_generate_v4(), 'b391df0d-0b29-4b9c-a254-0a0c2c0b70ff', 'f2e5bfa1-6711-4203-b13f-9f9a83b673a1', 1),

    -- Pedido 2: Monitor + Teclado + Mousepad
    (uuid_generate_v4(), 'a78b8848-fc5e-4a60-907d-f4a3e26ec0b7', '1e5ad5a7-995d-4b6c-b9c7-38c7a59d145b', 1),
    (uuid_generate_v4(), 'a78b8848-fc5e-4a60-907d-f4a3e26ec0b7', '6b7ccf5d-54d4-41c8-9d3a-cf58ec96f7b2', 1),
    (uuid_generate_v4(), 'a78b8848-fc5e-4a60-907d-f4a3e26ec0b7', 'b43a0d09-dc5d-4723-bb49-7e5441cf8a5c', 1),

    -- Pedido 3: SSD + RAM
    (uuid_generate_v4(), 'a6e66cd2-9d77-4f45-8d7b-89198a7bb46b', 'c9d1a8f3-8a2e-46e5-9b62-6d7e99ef3f1d', 1),
    (uuid_generate_v4(), 'a6e66cd2-9d77-4f45-8d7b-89198a7bb46b', 'dd49a7a1-9071-4b42-8e81-2124c6f5243f', 2),

    -- Pedido 4: Headset + Webcam
    (uuid_generate_v4(), '2e2b70b5-63ac-47a8-8a57-4d7dc5b1c7e2', 'e238c02a-6a4a-4805-864f-8bde5a7b71c0', 1),
    (uuid_generate_v4(), '2e2b70b5-63ac-47a8-8a57-4d7dc5b1c7e2', 'b1e27e1a-981d-45a7-9f64-f7c7ffb2a94f', 1),

    -- Pedido 5: Cadeira + Cabo
    (uuid_generate_v4(), '11b49e83-fd6b-4a1a-b537-2b5b9e3854d1', 'b0b611b8-1e25-4e1e-9e8f-51e0b176a3f2', 1),
    (uuid_generate_v4(), '11b49e83-fd6b-4a1a-b537-2b5b9e3854d1', 'c0c92f64-b615-4c71-bb07-88b9e4c37da4', 1),

    -- Pedido 6: Impressora + HD Externo
    (uuid_generate_v4(), '9fc9e5c3-3f12-48c9-b93e-d60a4f03f8f0', 'ea7201db-2f3f-4ee2-a9cf-25c8231f6c25', 1),
    (uuid_generate_v4(), '9fc9e5c3-3f12-48c9-b93e-d60a4f03f8f0', 'be79f62f-30f5-4a1f-9310-9d65b6e4158a', 1),

    -- Pedido 7: Mesa Wacom + Mousepad
    (uuid_generate_v4(), 'b3ee3f9b-bb61-4b93-a74f-1a4a816e354a', 'f3e70b11-33da-4ce8-a942-7842c4cfaf7a', 1),
    (uuid_generate_v4(), 'b3ee3f9b-bb61-4b93-a74f-1a4a816e354a', 'b43a0d09-dc5d-4723-bb49-7e5441cf8a5c', 1),

    -- Pedido 8: Roteador + Cabo HDMI (2)
    (uuid_generate_v4(), '0e3d7c9a-d3b9-4e8c-8829-b34488e86170', 'a64e11e1-05a5-4f35-9c51-b4c2e19bfe5b', 1),
    (uuid_generate_v4(), '0e3d7c9a-d3b9-4e8c-8829-b34488e86170', 'c0c92f64-b615-4c71-bb07-88b9e4c37da4', 2),

    -- Pedido 9: Mouse + Cabo HDMI
    (uuid_generate_v4(), '0836653d-d3ee-46e9-8e5c-776325fc5f03', 'f2e5bfa1-6711-4203-b13f-9f9a83b673a1', 1),
    (uuid_generate_v4(), '0836653d-d3ee-46e9-8e5c-776325fc5f03', 'c0c92f64-b615-4c71-bb07-88b9e4c37da4', 1),

    -- Pedido 10: Headset + Webcam
    (uuid_generate_v4(), '9a3f1183-5175-4c81-878d-540c3814b0e4', 'e238c02a-6a4a-4805-864f-8bde5a7b71c0', 1),
    (uuid_generate_v4(), '9a3f1183-5175-4c81-878d-540c3814b0e4', 'b1e27e1a-981d-45a7-9f64-f7c7ffb2a94f', 1),

    -- Pedido 11: Muitos Itens
    (uuid_generate_v4(), '9a3f1183-5175-4c81-878d-540c3814b0e4', 'd3a8c3f2-4c4f-4d4a-8e44-1bb08a19ef10', 1),
    (uuid_generate_v4(), '9a3f1183-5175-4c81-878d-540c3814b0e4', '1e5ad5a7-995d-4b6c-b9c7-38c7a59d145b', 1),
    (uuid_generate_v4(), '9a3f1183-5175-4c81-878d-540c3814b0e4', 'c9d1a8f3-8a2e-46e5-9b62-6d7e99ef3f1d', 1),
    (uuid_generate_v4(), '9a3f1183-5175-4c81-878d-540c3814b0e4', 'dd49a7a1-9071-4b42-8e81-2124c6f5243f', 1),
    (uuid_generate_v4(), '9a3f1183-5175-4c81-878d-540c3814b0e4', 'b0b611b8-1e25-4e1e-9e8f-51e0b176a3f2', 1),
    (uuid_generate_v4(), '9a3f1183-5175-4c81-878d-540c3814b0e4', 'ea7201db-2f3f-4ee2-a9cf-25c8231f6c25', 1),
    (uuid_generate_v4(), '9a3f1183-5175-4c81-878d-540c3814b0e4', 'be79f62f-30f5-4a1f-9310-9d65b6e4158a', 1),
    (uuid_generate_v4(), '9a3f1183-5175-4c81-878d-540c3814b0e4', 'f3e70b11-33da-4ce8-a942-7842c4cfaf7a', 1),
    (uuid_generate_v4(), '9a3f1183-5175-4c81-878d-540c3814b0e4', 'a64e11e1-05a5-4f35-9c51-b4c2e19bfe5b', 1),
    (uuid_generate_v4(), '9a3f1183-5175-4c81-878d-540c3814b0e4', 'c0c92f64-b615-4c71-bb07-88b9e4c37da4', 1)
ON CONFLICT DO NOTHING;


-- ========================================
-- Comentários nas tabelas e colunas
-- ========================================
COMMENT ON TABLE public.produtos IS 'Tabela de produtos disponíveis para pedidos';
COMMENT ON TABLE public.pedidos IS 'Tabela de pedidos realizados';
COMMENT ON TABLE public.itens_pedido IS 'Tabela de itens de cada pedido';
COMMENT ON TABLE public.entregas IS 'Tabela de entregas vinculadas aos pedidos';

COMMENT ON COLUMN public.pedidos.status IS 'Status do pedido: pendente, em_preparacao, pronto, em_entrega, entregue, cancelado';
COMMENT ON COLUMN public.entregas.status IS 'Status da entrega: aguardando, em_rota, entregue, cancelada';
COMMENT ON COLUMN public.entregas.id_integrador IS 'Referência ao usuário do Supabase Auth responsável pela entrega';
COMMENT ON COLUMN public.entregas.observacoes IS 'Observações sobre a entrega (opcional)';
COMMENT ON COLUMN public.entregas.entregue_para IS 'Nome da pessoa que recebeu a entrega (opcional)';
