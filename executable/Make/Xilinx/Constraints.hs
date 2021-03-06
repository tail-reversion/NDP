module Make.Xilinx.Constraints (ucfRules) where

import Data.ByteString.Builder
import qualified Data.ByteString.Lazy as B
import Data.Conf
import Data.List
import Data.Monoid
import Development.Shake
import Development.Shake.Config
import Development.Shake.FilePath

import Make.Config
import Resources.Constraints

-- I want a shorter name for this
utf8 :: String -> Builder
utf8 = stringUtf8

ucfRules :: Rules ()
ucfRules = do
  (Just xilinxD) <- liftIO $ getConfigIO "XILINX_OUT"

  (xilinxD </> "*.ucf") %> \ ucF -> do
    let entityName = takeBaseName ucF

    -- read config vars
    (Just masterConstraintsF) <- getConfig "FPGA_CONSTRAINTS"
    (Just entityD) <- getConfig "TOPLEVEL_ENTITIES"
    -- (Just mainClashNameF) <- getConfig "TOPLEVEL_HS_FILE"
    (Just constraintsF) <- getConfig "ENTITY_CONFIG_SETTINGS"

    need [masterConstraintsF,
          entityD </> entityName </> constraintsF]

    -- read from constraint files
    masterConstraints <- liftIO $ readConf masterConstraintsF
    entityConstraints <- (liftIO . readConf) $ entityD </> entityName </> constraintsF

    -- determine constraints worth fetching
    let (Just constraintTags) = (getConf "constraints" entityConstraints) :: Maybe [String]

    constraintBuilders <- (flip mapM) constraintTags $ \ tag -> do
      let (Just constraints) = (getConf tag masterConstraints) :: Maybe Constraints
      return $ renderConstraints constraints

    (liftIO . B.writeFile ucF . B.concat . map toLazyByteString) constraintBuilders

renderConstraints :: Constraints -> Builder
renderConstraints cs = renderLines (rawB ++ netB)
  where rawB = map stringUtf8 (rawConstraints cs)
        netB = map renderNet (netConstraints cs)

renderLines :: [Builder] -> Builder
renderLines lns = mconcat [ ln <> stringUtf8 ";\n" | ln <- lns ]

renderNet :: (String, [NetParameter]) -> Builder
renderNet (name, attrs) = net <> spc <> netName <> spc <> renderAttribs attrs
  where net = stringUtf8 "NET"
        netName = stringUtf8 name
        spc = charUtf8 ' '

renderNetParameter :: NetParameter -> Builder
renderNetParameter (NetFlag f)        = stringUtf8 f
renderNetParameter (NetKV l r) = utf8 l <> utf8 " = " <> utf8 r
renderNetParameter complexParam = renderNetParameter simpleParam
  where simpleParam = flattenNetParameter complexParam

renderAttribs :: [NetParameter] -> Builder
renderAttribs attr = mconcat $ intersperse sep $ map renderNetParameter attr
  where sep = stringUtf8 " | "
